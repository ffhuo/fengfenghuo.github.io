#!/usr/bin/perl
use strict;
use warnings;
use Encode;
use File::Basename;
use File::Find;
use File::Spec;
use Data::Dumper;

my $root_dir = dirname($0);

my @to_process_files;
sub process {
  my $file = $File::Find::name;
  return if $file !~ m/\.md$/;

  push @to_process_files, $file;
}

find(\&process, $root_dir . "/");

foreach my $file (@to_process_files) {
  my @file_dir = File::Spec->splitdir( dirname($file) );
  my $file_name = decode("utf8", fileparse($file, ("md")));
  $file_name =~ s/\.$//;

  open(my $fh, '<:encoding(UTF-8)', $file)
    or die "Could not open file '$file' $!\n";

  my @output_lines;
  my $need_update = 0;
  my $line = 0;
  while (my $row = <$fh>) {
    chomp($row);

    $line++;
    push @output_lines, $row
      and next if $row !~ m/\!\[([^]]*)\]\(([^)]+)\)/;

    my $pic_name = $1;
    my $pic_path = $2;

    #图片名字校验
    print "$file:$line: 图片名字 [" . encode("utf8", $pic_name) . "] 格式错误\n"
      and push @output_lines, $row
      and next if $pic_name =~ m/[.|]/;

    print "$file:$line: 图片名字没有配置\n"
      and push @output_lines, $row
      and next if $pic_name =~ m/^\s*$/;

    #图片位置校验
    print "$file:$line: 图片 (" . encode("utf8", $pic_path) . ") 放置位置错误\n"
      and push @output_lines, $row
      and next if $pic_path !~ m/^media\//;

    #图片存在性判断
    my @pic_dir = map { encode("utf8", $_) } File::Spec->splitdir( $pic_path );
    my $pic_full_path = File::Spec->catfile(@file_dir, @pic_dir);
    print "$file:$line: 图片 (" . encode("utf8", $pic_path) . ") 不存在\n"
      and push @output_lines, $row
      and next if not -e $pic_full_path;

    $pic_path =~ m/\.([^.]+)$/;
    my $pic_file_postfix = $1;
    my $suggest_pic_path = "media/$file_name-" . "$pic_name.$pic_file_postfix";
    if ($pic_path ne $suggest_pic_path) {
      my @suggest_pic_dir = map { encode("utf8", $_) } File::Spec->splitdir( $suggest_pic_path );
      my $suggest_pic_full_path = File::Spec->catfile(@file_dir, @suggest_pic_dir);

      print "$file:$line: rename " . encode("utf8", $pic_path) . " ==> " . encode("utf8", $suggest_pic_path) . " fail, $!\n"
      and push @output_lines, $row
      and next if not rename $pic_full_path, $suggest_pic_full_path;

      $row =~ s/\!\[([^]]*)\]\([^)]+\)/\![$1]($suggest_pic_path)/;
      $need_update = 1;
    }

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
  }
}

1;
