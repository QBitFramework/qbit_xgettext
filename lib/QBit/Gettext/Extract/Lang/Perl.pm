package QBit::Gettext::Extract::Lang::Perl;

use qbit;
use Text::Balanced qw(extract_multiple extract_quotelike);

use base qw(QBit::Gettext::Extract::Lang);

my $RE_eol        = $QBit::Gettext::Extract::Lang::RE_eol;

sub extract_from_file {
    my ($self, $filename, $po) = @_;

    my @quoted = grep {defined($_)} map {scalar extract_quotelike($_)} extract_multiple(readfile($filename), [\&extract_quotelike]);
    if(@quoted) {
        my $quoted_regexp = '(?:'.join(')|(?:', map {quotemeta($_)} @quoted).')';
        local $QBit::Gettext::Extract::Lang::RE_quoted_str = qr/(?:$QBit::Gettext::Extract::Lang::RE_quoted_str)|$quoted_regexp/ ;
        $self->SUPER::extract_from_file($filename, $po);
    }
    else {
        $self->SUPER::extract_from_file($filename, $po);
    }
}

sub clean {
    my ($self, $text) = @_;

    {
        no warnings qw(uninitialized);
        $text =~ s/($QBit::Gettext::Extract::Lang::RE_quoted_str)|#.*$/$1/mg;    # Remove comments
    };

    # Remove PODs
    while ($text =~ /^(.*?(?:^|$RE_eol))(=\w.+?(?:$RE_eol=cut|$))(.*)$/sg) {
        my ($prev_text, $pod_text, $post_text) = ($1, $2, $3);
        $pod_text =~ s/^.*$//mg;
        $text = $prev_text . $pod_text . $post_text;
    }

    return $text;
}

TRUE;
