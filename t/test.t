# 
# <C> Richard Foley RFI 2001 file-regex@rfi.net
# tests for File::Content 

use Data::Dumper;
use File::Content;
use Test;
use strict;
plan('tests' => 11);
my $i_test = 0;
my $i_errs = 0;

my $ro = './t/read.txt ';
my $rw = './t/write.txt';
my $ur = './t/unreal.txt';

# CREATE 1
# =============================================================================
$i_test++;
$i_errs = 0;

my $o_rw = File::Content->new($rw);
$i_errs++ unless ref($o_rw);
print "[$i_test] read-write file($rw) => o_rw($o_rw)\n" if $i_errs;

my $o_ro = File::Content->new($ro, 'ro');
$i_errs++ unless ref($o_ro);
print "[$i_test] read-only file($ro) => o_ro($o_ro)\n" if $i_errs;

my $o_ex = File::Content->new($rw, ' +< ');
$i_errs++ unless ref($o_ex);
print "[$i_test] read-write file($rw) => o_ex($o_ex)\n" if $i_errs;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

# DUFF 2 
# =============================================================================
$i_test++;
$i_errs = 0;

my $o_ur = File::Content->new($ur);
$i_errs++ if ref($o_ur);
print "[$i_test] read-write file($ur) => o_ur($o_ur)\n" if $i_errs;

my $o_x = File::Content->new();
$i_errs++ if ref($o_x);
print "[$i_test] read-write file() => o_x($o_x)\n" if $i_errs;

my $o_xx = File::Content->new($rw, ' << ');
$i_errs++ if ref($o_xx);
print "[$i_test] read-write file($rw) => o_xx($o_xx)\n" if $i_errs;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

=pod
# STAT 2
# =============================================================================
$i_test++;
$i_errs = 0;

my $i_stat = my @stat = File::Content->new($ro)->fstat('_');
print "i_stat($i_stat) stat(@stat): ".Dumper(\@stat);
$i_errs++ unless $i_stat >= 3;
print "[$i_test] stat\n" if $i_errs;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================
=cut

# READ 3
# =============================================================================
$i_test++;
$i_errs = 0;

my $i_ro = my @read = $o_ro->read('.+');
$i_errs++ unless $i_ro >= 3;
print "[$i_test] read contains $i_ro lines\n" if $i_errs;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

# WRITE 3
# =============================================================================
$i_test++;
$i_errs = 0;

my $i_wr = my @writ = $o_rw->write(
	"here is some irrelevant\n",
	"	test data that should end up in the file\n",
	"\n",	
	"	somewhere\n",
);
$i_errs++ unless $i_wr == 4;
print "[$i_test] write contains $i_wr lines(@writ)\n" if $i_errs;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

# ACCESS 4
# =============================================================================
$i_test++;
$i_errs = 0;

my $i_x = my @x = $o_ro->insert(2, "bad insert stuff");
$i_errs++ if $i_x || @x;
foreach my $attempt (qw(append prepend replace write)) {
	my $i_x = my @x = $o_ro->$attempt("bad $attempt ", "bad stuff");
	if ($i_x || @x) {
		$i_errs++;
		print "wrote($attempt) to read-only($i_x) file(@x)!\n";
	}
}

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

# PREPEND 5
# =============================================================================
$i_test++;
$i_errs = 0;

my $pre = "prepended this stuff\n";
my $i_pre = my @pre = $o_rw->prepend($pre);
$i_errs++ unless $pre[0] eq $pre;
print "[$i_test] prepend(@pre)\n" if $i_errs;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

# INSERT 6
# =============================================================================
$i_test++;
$i_errs = 0;

my $ins = "inserted some stuff at line 2\n";
my $i_ins = my @ins = $o_rw->insert(2, $ins); 
$i_errs++ unless $ins[2] eq $ins;
print "[$i_test] insert(@ins)\n" if $i_errs;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

# APPEND 7
# =============================================================================
$i_test++;
$i_errs = 0;

my $app = "appended that stuff\n";
my $i_app = my @app = $o_rw->append($app);
$i_errs++ unless $app[0] eq $app;
print "[$i_test] append(@app)\n" if $i_errs;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

# SEARCH 8
# =============================================================================
$i_test++;
$i_errs = 0;

$File::Content::STRING = 0;
my $str0 = 'ed\s*(\w+\s*\w{2})uff';
my $i_str0 = my @str0 = $o_rw->search($str0);
$i_errs++ unless $str0[1] eq 'some st';
print "str0($str0): err($i_errs) ".Dumper(\@str0) if $i_errs;

$File::Content::STRING = 1;
my $str1 = '(?sm:line\s*(\w+)\s*(\w+))';
my $i_str1 = my @str1 = $o_rw->search($str1);
$i_errs++ unless $str1[0] == 2 && $str1[1] eq 'test';
print "str1($str1): err($i_errs) ".Dumper(\@str1) if $i_errs;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

# REPLACE 9
# =============================================================================
$i_test++;
$i_errs = 0;

$File::Content::STRING = 0;
my $sea0 = '(ed)\s+'; my $rep0 = 'ED ';
my $i_sea0 = my @snr0 = $o_rw->replace($sea0 => $rep0);
$i_errs++ unless $snr0[2] =~ /^insertED some stuff at line 2$/;
print "sea0($sea0) rep($rep0): i($i_sea0) err($i_errs) ".Dumper(\@snr0) if $i_errs;

$File::Content::STRING = 1;
my $sea1 = '(ED)\s+'; my $rep1 = 'Ed ';
my $i_sea1 = my @snr1 = $o_rw->replace($sea1 => $rep1);
$i_errs++ unless $snr1[0] =~ /insertEd some stuff at line 2/s;
print "sea1($sea1) rep($rep1): i($i_sea1) err($i_errs) ".Dumper(\@snr1) if $i_errs;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

# Feedback 10
# =============================================================================
$i_test++;
$i_errs = 0;

print $o_rw->_vars if $File::Content::DUMP;

($i_errs == 0) ? ok(1) : ok(0);
# =============================================================================

package File::Content::Test;

sub new { return  bless({}, shift); }

sub read {
	my $self = shift;
	my $err  = join('', @_);
	my $length = length($err);
	print "read failure handler - length($length):\n  $err\n";
}

sub error { # returns length of arg string/s
	my $self = shift;
	my $err  = join('', @_);
	my $length = length($err);
	print "error failure handler - length($length):\n  $err\n";
}

1;

# =============================================================================

__END__

# reuse
$i_test++;
my $o_reuse = File::Content->new($rw);
print "[$i_test] re-use for file($rw) => o_reuse($o_reuse)\n";
(ref($o_reuse)) ? ok(4) : ok(0);

# error handler
$i_test++;
undef $o_rw; # close it
my $o_err = File::Content->new('hopefully_NON-existent->file :-)',
		'open'		=> File::Content::Test->new,
		'init'		=> File::Content::Test->new,
		'extract'	=> File::Content::Test->new,
);
my $i_err = my @errs = $o_err->extract('.+');
print "[$i_test] err extract $i_err line/s (@errs)\n";
($i_err) ? ok(9) : ok(0);

# error handler
$i_test++;
undef $o_rw; # close it
my $i_err = my @err = File::Content->new('hopefully_NON-existent->file :-)',
		'error'	=> \&error_handler,
	
)->extract('.+');
print "[$i_test] reread $i_read line/s (@read)\n";
($i_read == $i_wrote_cnt) ? ok(9) : ok(0);

sub error_handler {
	my $err  = join('', @_);
	print 'error_handler: '.length($err)."\n";
}

# done

