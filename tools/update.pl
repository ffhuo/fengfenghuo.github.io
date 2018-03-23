#!/usr/bin/perl
use strict;
use warnings;
use Encode;
use Cwd;
use File::Basename;
use File::Find;
use File::Spec;
use Data::Dumper;

binmode(STDOUT, ":utf8");

my $root_dir;
my @root_dir_sep = File::Spec->splitdir(dirname($0));
while (@root_dir_sep and $root_dir_sep[0] eq '.') {
  shift @root_dir_sep;
}

if (@root_dir_sep == 0) {
  $root_dir = ".."
}
elsif (@root_dir_sep == 1) {
  $root_dir = ".";
}
else {
  $root_dir = File::Spec->catfile(@root_dir_sep[0 .. $#root_dir_sep - 1]);
}

my %pic_repo;
my %doc_repo;

sub process_pic_ref;
sub process_doc_ref;

sub process {
  my $file = decode("utf8", $File::Find::name);
  my $base_name = decode("utf8", $_);

  if ($base_name =~ m/\.md$/) {
      if (exists $doc_repo{$base_name}) {
        print $file . ": duplicate at $doc_repo{$base_name}->{path}\n";
      }
      else {
        $doc_repo{$base_name} = { path => $file, used_by => {} };
      }
  }

  if ($base_name =~ m/\.png$/
      || $base_name =~ m/\.jpg$/
      || $base_name =~ m/\.jpeg$/
      || $base_name =~ m/\.gif$/
     )
    {
      if (exists $pic_repo{$base_name}) {
        print $file . ": duplicate at $pic_repo{$base_name}->{path}\n";
      }
      else {
        $pic_repo{$base_name} = { path => $file, used_by => {} };
      }
    }
}

find(\&process, $root_dir . "/");

foreach my $file_name_with_postfix (keys %doc_repo) {
  my $file_data = $doc_repo{$file_name_with_postfix};
  my $file = $file_data->{path};

  open(my $fh, '<:encoding(UTF-8)', encode("utf8", $file))
    or die "Could not open file '$file' $!\n";

  my @output_lines;
  my $need_update = 0;
  my $line = 0;
  while (my $row = <$fh>) {
    chomp($row);

    $line++;

    $need_update = 1 if process_pic_ref($file, $line, \$row);
    $need_update = 1 if process_doc_ref($file, $line, \$row);

    push @output_lines, $row;
  }

  close($fh);

  if ($need_update) {
    open(my $fh, '>:encoding(UTF-8)', $file)
      or die "Could not open file '$file' $!\n";

    foreach my $row ( @output_lines ) {
      print $fh $row;
      print $fh "\n";
    }

    close $fh;

    print "$file updated\n";
  }
}

sub process_pic_ref {
  my $file = shift;
  my $line = shift;
  my $row = shift;

  my @file_dir = File::Spec->splitdir( dirname($file) );
  my $file_name = fileparse($file, ("md"));
  $file_name =~ s/\.$//;

  return 0 if ${ $row } !~ m/\!\[([^]]*)\]\(([^)]+)\)/;

  my $pic_name = $1;
  my $pic_path = $2;

    #图片名字校验
  print "$file:$line: " . decode("utf8", "图片名字") . " [$pic_name] " . decode("utf8", "格式错误"). "\n"
    and return 0 if $pic_name =~ m/[.|]/;

  print "$file:$line: " . decode("utf8", "图片名字没有配置") . "\n"
    and return 0 if $pic_name =~ m/^\s*$/;

  #图片位置校验
  print "$file:$line: " . decode("utf8", "图片") . " ($pic_path) " . decode("utf8", "放置位置错误") . "\n"
    and return 0 if $pic_path !~ m/^media\//;

  my $need_update = 0;

  #图片存在性判断
  my @pic_dir = File::Spec->splitdir( $pic_path );
  my $pic_full_path = File::Spec->catfile(@file_dir, @pic_dir);
  my $pic_exist = -e encode("utf8", $pic_full_path);
  my $pic_base_name = $pic_dir[$#pic_dir];
  my $pic_data = $pic_repo{$pic_base_name};
  $pic_path =~ m/\.([^.]+)$/;
  my $pic_file_postfix = $1;
  my $suggest_pic_path = "media/$file_name-" . "$pic_name.$pic_file_postfix";
  my @suggest_pic_dir = File::Spec->splitdir( $suggest_pic_path );
  my $suggest_pic_full_path = File::Spec->catfile(@file_dir, @suggest_pic_dir);

  if (not defined $pic_data) {
    if (not $pic_exist) {
      print "$file:$line: " . decode("utf8", "图片") . " ($pic_path) " . decode("utf8", "不存在"). "\n";
    }
    else {
      print "$file:$line: " . decode("utf8", "图片") . " ($pic_path) " . decode("utf8", "与磁盘文件名大小写不匹配") . "\n";
    }
    next;
  }

  $pic_data->{used_by}->{$file} = [] if not exists $pic_data->{used_by}->{$file};
  push @{ $pic_data->{used_by}->{$file} }, $line;

  if (not $pic_exist or $pic_path ne $suggest_pic_path) {
    my $suggest_pic_full_dir = dirname($suggest_pic_full_path);
    mkdir $suggest_pic_full_dir if not -e $suggest_pic_full_dir;

    print "$file:$line: rename $pic_path ==> $suggest_pic_path fail, $!\n"
      and return 0 if not rename encode("utf8", $pic_data->{path}), encode("utf8", $suggest_pic_full_path);

    ${ $row } =~ s/\!\[([^]]*)\]\([^)]+\)/\![$1]($suggest_pic_path)/;
    $need_update = 1;
  }

  return $need_update;
}

sub process_doc_ref {
  my $file = shift;
  my $line = shift;
  my $row = shift;

  my @file_dir = File::Spec->splitdir( dirname($file) );
  my $file_name = fileparse($file, ("md"));
  $file_name =~ s/\.$//;

  my $need_update = 0;

  my @matchs = ( ${ $row } =~ m/(?:[^!]|^)\[([^]]*)\]\(([^)]+)\)/g );
  while ( @matchs ) {
    my $doc_name = shift @matchs;
    my $doc_path = shift @matchs;

    #print "$file:$line: $doc_name ==> $doc_path\n";

    next if $doc_path =~ m/^http/;

    my $doc_full_path = File::Spec->rel2abs(File::Spec->join(dirname($file), $doc_path));

    if ($doc_path !~ m/([^\/]+\.md$)/) {
      print "$file:$line: " . decode("utf8", "资源") . " ($doc_path) " . decode("utf8", "不存在") . "\n"
        if not -e encode("utf8", $doc_full_path);
      next;
    }

    my $doc_base_name = $1;
    my $doc_data = $doc_repo{$doc_base_name};
    my $doc_exist = -e encode("utf8", $doc_full_path);

    if (not defined $doc_data) {
      if ($doc_exist) {
        print "$file:$line: " . decode("utf8", "文档") . " ($doc_path) " . decode("utf8", "不存在") . "\n";
      }
      else {
        print "$file:$line: " . decode("utf8", "文档") . " ($doc_path) " . decode("utf8", "与磁盘文件名大小写不匹配") . "\n";
      }
      next;
    }

    if (not $doc_exist) {
      my $ref_doc_path_abs = File::Spec->rel2abs($doc_data->{path});
      my $file_abs = File::Spec->rel2abs(dirname($file));
      my $ref_doc_path_rel = File::Spec->abs2rel($ref_doc_path_abs, $file_abs);

      ${ $row } =~ s/\[$doc_name\]\([^)]+\)/[$doc_name]($ref_doc_path_rel)/;
      $need_update = 1;
    }

    $doc_data->{used_by}->{$file} = [] if not exists $doc_data->{used_by}->{$file};
    push @{ $doc_data->{used_by}->{$file} }, $line;
  }

  return $need_update;
}

while ((my $pic_base_name, my $pic_data) = each %pic_repo) {
  if (! keys %{ $pic_data->{used_by} }) {
    print "$pic_data->{path}: no ref, need remove\n";
    # print "$pic_data->{path}: no ref, auto remove fail, $!\n"
    #   if not unlink encode("utf8", $pic_data->{path});
  }
}

while ((my $doc_base_name, my $doc_data) = each %doc_repo) {
  my $doc_path = $doc_data->{path};
  my $doc_rel_path = File::Spec->abs2rel($doc_path, $root_dir);
  next if $doc_rel_path =~ m/^[^\/]+$/;

  if (! keys %{ $doc_data->{used_by} }) {
    print "$doc_path: " . decode("utf8", "没有任何引用，需要链接到文档树") . "\n";
  }
}

1;
