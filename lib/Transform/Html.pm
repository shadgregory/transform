package Transform::Html;
use Exporter qw(import);
use HTML::Tidy;    #sudo apt-get install libhtml-tidy-perl
 
our @EXPORT_OK = qw(transform);

sub new {
    my $self = {};
    bless $self;
    return $self;
}

#transform perl hash to html
sub _process_hash {
    my ( $self, $data_struct ) = @_;
    die "Error: Invalid Hash" if ( ref($data_struct) ne 'HASH' );
    return "<dl></dl>" if ( keys %{$data_struct} == 0 );
    my $hash_string = "<dl>";
    my @keys        = keys %{$data_struct};
    for ( my $i = 0; $i < @keys; $i++ ) {
        if ( ref( $data_struct->{ $keys[$i] } ) eq 'ARRAY' ) {
            $hash_string
              .= '<dt>'
              . $keys[$i]
              . "</dt><dd>"
              . $self->_process_array( $data_struct->{ $keys[$i] } ) . "</dd>";
        }
        elsif ( ref( $data_struct->{ $keys[$i] } ) eq 'HASH' ) {
            $hash_string
              .= '<dt>'
              . $keys[$i]
              . "</dt><dd>"
              . $self->_process_hash( $data_struct->{ $keys[$i] } ) . "</dd>";
        }
        else {
            $hash_string
              .= '<dt>' . $keys[$i] . "</dt><dd>" . $data_struct->{ $keys[$i] } . "</dd>";
        }
    }
    $hash_string .= "</dl>";
}

#transform perl array to html
sub _process_array {
    my ( $self, $data_struct ) = @_;
    die "Error: Invalid Array" if ( ref($data_struct) ne 'ARRAY' );
    return "<ol></ol>" if ( @{$data_struct} == 0 );
    my $array_string = "<ol>";
    for ( my $i = 0; $i < @{$data_struct}; $i++ ) {
        if ( ref( $data_struct->[$i] ) eq 'ARRAY' ) {
            $array_string .= '<li>' . $self->_process_array( $data_struct->[$i] ) . "</li>";
        }
        elsif ( ref( $data_struct->[$i] ) eq 'HASH' ) {
            $array_string .= '<li>' . $self->_process_hash( $data_struct->[$i] ) . "</li>";
        }
        else {
            $array_string .= '<li>' . $data_struct->[$i] . "</li>";
        }
    }
    $array_string .= "</ol>";
}

#Returns HTML string based on an arbitrary perl data structure
sub transform {
    my ( $self, $data_struct ) = @_;
    if ( ref($data_struct) eq 'ARRAY' ) {
        $self->_process_array($data_struct);
    }
    elsif ( ref($data_struct) eq 'HASH' ) {
        $self->_process_hash($data_struct);
    }
    else {
        die "Top structure must be an array or a hash";
    }
}
1;
