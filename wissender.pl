#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Std;

package Wissender;
use base 'Bot::BasicBot';

sub init {
    my $self = shift;

    # get answers from DATA section
    my @answers;
    my $i = -1;
    foreach my $line (<main::DATA>) {

        # cleanup
        chomp $line;
        next if $line =~ /^\s*$/;

        # next lines go to the next answer array
        $answers[++$i] = [] and next if $line =~ /^\d+:$/;

        # insert
        push @{$answers[$i]}, $line;
    }

    # inject
    $self->{answers} = \@answers;

    # everything ok
    return 1;
}

sub said {
    my ($self, $said) = @_;

    # channel message
    return unless $said->{channel} ~~ $self->{channels};

    # highlight
    my $nick = $self->{nick};
    return unless $said->{address} and $said->{address} =~ /$nick/;

    # question
    return unless $said->{raw_body} =~ /\?( *)$/;

    # generate an answer
    my $spaces  = length $1;
    my $answers = $self->{answers}[$spaces] // ['42.'];
    return $answers->[rand @$answers];
}

package main;

# get command line options
my %opt;
getopt('hdspcnur', \%opt);

# help message
if ($opt{h} or not keys %opt) { print <<'EOF'; exit }

WISSENDER

An IRC bot that seems to know all answers. Valid questions include a highlight,
a question mark and can be answered with yes or no:

    Wissender: is Bin Laden dead?

The bot's answer depends on the number of spaces after the question mark:

    0 spaces: bot doesn't know
    1 space : no
    2 spaces: hm, no
    3 spaces: hm, yes
    4 spaces: absolutely

You can change the bot's possible answers by changing the DATA section of this
script. By default they're german.

COMMAND LINE OPTIONS

When called without options or with -h, this help message will show up.
Other options:

    -d                  use default values but don't show the help message
    -s irc.perl.org     irc server
    -p 6666             irc server port
    -c '#foo,#bar'      quoted (!) comma-separated list of channels
    -n knowy            the bot's nick name
    -u knowy42          the bot's user name
    -r 'Foo Bar'        the bot's real name

EXAMPLE

    $ wissender.pl -s irc.perl.org -p 6667 -c '#mojo' -n sr1

EOF

# create and run the bot
Wissender->new(
    server      => $opt{s} // 'irc.quakenet.org',
    port        => $opt{p} // '6667',
    channels    => [ split /,/ => $opt{c} // '#html.de.selbsthilfe' ],
    nick        => $opt{n} // 'Wissender',
    username    => $opt{u} // 'wissender',
    name        => $opt{r} // 'Der Wissende',
)->run;

__DATA__

0:
Keine Ahnung.
Das weiß ich nicht.
Sorry, da bin ich ahnungslos.

1:
Auf keinen Fall!
Niemals!
Nein.

2:
Hmm, eher nicht.
Wohl kaum.
Wohl nicht.
Wahrscheinlich nicht.
Eher nicht.

3:
Kann gut sein.
Wär schon möglich.
Hmja, naja, ja.
Ja, vielleicht schon.

4:
Auf jeden Fall.
Ganz sicher, ja.
Ja!
Ja.
