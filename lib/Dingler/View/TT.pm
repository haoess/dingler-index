package Dingler::View::TT;
use parent 'Catalyst::View::TT';

use strict;
use warnings;

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    WRAPPER            => 'wrapper.tt',
    ENCODING           => 'utf-8',
    render_die         => 0,
);

1;
__END__

=head1 NAME

Dingler::View::TT - TT View for Dingler

=head1 DESCRIPTION

TT View for Dingler.

=head1 SEE ALSO

L<Dingler>

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
