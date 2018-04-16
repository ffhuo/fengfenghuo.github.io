#!/usr/bin/perl
use strict;
use warnings;
use Encode;
use File::Basename;
use File::Find;
use File::Spec;
use Getopt::Long;
use Data::Dumper;

my $user_name;
GetOptions("user|u=s" => \$user_name);

if (defined $user_name and $user_name eq "self") {
  open(my $fh, '<:encoding(UTF-8)', "~/.gitconfig")
    or die "无法打开 ~/.gitconfig 读取默认用户名 $!\n";

  close $fh;
}

my $root_dir = dirname($0);

my @to_process_files;
sub process {
  my $file = $File::Find::name;
  return if $file !~ m/\.md$/;

  push @to_process_files, $file;
}

find(\&process, $root_dir . "/");

my @todos;
foreach my $file (@to_process_files) {
  my @file_dir = File::Spec->splitdir( dirname($file) );
  my $file_name = decode("utf8", fileparse($file, ("md")));
  $file_name =~ s/\.$//;

  open(my $fh, '<:encoding(UTF-8)', $file)
    or die "Could not open file '$file' $!\n";

  my $line = 0;
  my $effective_row = 0;
  while (my $row = <$fh>) {
    chomp($row);

    $line++;

    next if $row =~ /^\s*$/;
    next if $row =~ /^#\s+/;

    $effective_row++;

    next if $row !~ m/\<!--\s+TODO:\s*(.*)\s+-->/;

    my $contant = $1;
    my $owner = "";
    my $priority = "C";

    if ($contant =~ m/@([^\s]+)/) {
      $owner = $1;
      $contant =~ s/\s*@[^\s]+\s*/ /;
    }

    if ($contant =~ m/#([ABCD])/) {
      $priority = $1;
      $contant =~ s/\s*#[ABCD]\s*/ /;
    }

    $contant =~ s/^\s*(.*)\s*$/$1/;

    push @todos, { file => $file, line => $line, owner => $owner, priority => $priority, msg => $contant }
  }

  close($fh);

  if ($effective_row < 3) {
    push @todos, { file => $file, line => 1, owner => "", priority => "C", msg => decode("utf8", "补充完整《") . $file_name . decode("utf8", "》的内容") }
  }
}

my %user_todos;
foreach my $todo ( @todos ) {
  my $user = $todo->{owner};
  $user_todos{$user} = [] if not exists $user_todos{$user};
  push @{ $user_todos{$user} }, $todo;
}

sub report_todo {
  (my $user_key, my $user_name) = @_;

  print "\n*** $user_name ***\n";

  my @cur_user_todos = ();
  @cur_user_todos = @{ $user_todos{$user_key} } if exists $user_todos{$user_key};

  if (!@cur_user_todos) {
    print "    恭喜,所有的任务都已经完成\n";
  }
  else {
    @cur_user_todos = sort { $a->{priority} cmp $b->{priority} } @cur_user_todos;
    foreach my $todo ( @cur_user_todos ) {
      print "$todo->{file}:$todo->{line}: [$todo->{priority}] " . encode("utf8", $todo->{msg}) . "\n";
    }
  }
}

if (defined $user_name) {
  report_todo($user_name, $user_name);
}
else {
  my @users = grep { $_ ne "" } keys %user_todos;
  foreach my $user ( @users ) {
    report_todo($user, $user);
  }

  if (exists $user_todos{""}) {
    report_todo("", "未分配");
  }
}

1;
