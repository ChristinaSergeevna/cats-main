package CATS::Messages;

use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(msg res_str);

use Carp qw(croak);
use File::Spec;

use CATS::Config qw(cats_dir);
use CATS::Constants;
use CATS::Settings;

my ($resource_strings, $messages);

sub _init_res_str_lang {
    my ($lang) = @_;
    my $file = File::Spec->catfile(cats_dir(), '..', 'tt', 'lang', $lang, 'strings');

    my $r = [];
    open my $f, '<', $file or die "Couldn't open resource strings file: '$file'.";
    binmode($f, ':utf8');
    while (my $line = <$f>) {
        $line =~ m/^(\d+)\s+\"(.*)\"\s*$/ or next;
        $r->[$1] and die "Duplicate resource string id: $1";
        $r->[$1] = $2;
    }
    $r;
}

sub init {
    # Preserve resource strings between http requests.
    $resource_strings //= { map { $_ => _init_res_str_lang($_) } @cats::langs };
    $messages = [];
}

sub res_str {
    my ($id, @params) = @_;
    my $s = $resource_strings->{CATS::Settings::lang()}->[$id] or die "Unknown res_str id: $id";
    sprintf($s, @params);
}

sub msg {
    push @$messages, res_str(@_);
    # Support 'return msg' pattern.
    undef;
}

sub msg_debug {
    # sprintf forces scalar context of format.
    push @$messages, sprintf(shift, @_);
    undef;
}

sub get { $messages }

sub problem_status_names() {+{
    $cats::problem_st_manual    => res_str(700),
    $cats::problem_st_ready     => res_str(701),
    $cats::problem_st_compile   => res_str(705),
    $cats::problem_st_suspended => res_str(702),
    $cats::problem_st_disabled  => res_str(703),
    $cats::problem_st_hidden    => res_str(704),
}}

1;
