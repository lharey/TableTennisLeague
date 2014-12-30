package TableTennisLeague::View::Email;

use strict;
use base 'Catalyst::View::Email';

__PACKAGE__->config(
    stash_key => 'email'
);

=head1 NAME

TableTennisLeague::View::Email - Email View for TableTennisLeague

=head1 DESCRIPTION

View for sending email from TableTennisLeague. 

=head1 AUTHOR

Lisa Hare,,,,

=head1 SEE ALSO

L<TableTennisLeague>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
