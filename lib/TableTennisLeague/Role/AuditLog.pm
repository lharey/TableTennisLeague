=head1 NAME

TableTennisLeague::Role::AuditLog

=head1 DESCRIPTION

Role for logging entries to the audit_log table

=cut

package TableTennisLeague::Role::AuditLog;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;
use JSON::MaybeXS;

sub audit :Private {
    my ($self, $c, $args) = @_;

    my $request = $c->req;
    my $content = $args->{content} || $request->data;
    my $dt = DateTime->now();

    my $params = {
        ip_address => $request->address,
        action => $args->{action} || $request->method,
        path => $args->{path} || $request->_path,
        content => encode_json($content),
        audit_date => $dt->ymd('-') . ' ' . $dt->hms(':')
    };

    eval { $c->model('DB::AuditLog')->create($params); };

    return;
}

1;
