package Transform::Javascript;
use Exporter qw(import);
use Scalar::Util qw(refaddr);
 
our @EXPORT_OK = qw(transform);

sub new {
    my $self = {};
    bless $self;
    return $self;
}

#transform perl array to javascript
sub _process_array {
    my ( $self, $data_struct, %history ) = @_;
    die "Error: Invalid Array" if ( ref($data_struct) ne 'ARRAY' );
    return "[]" if ( @{$data_struct} == 0 );
    if (!%history) {
        %history = ();
    }
    $history{refaddr($data_struct)} = 1 if (refaddr($data_struct));
    my $array_string = "[";
    for ( my $i = 0; $i < @{$data_struct}; $i++ ) {
        if (refaddr($data_struct->[$i]) && exists $history{refaddr($data_struct->[$i])}) {
            die "Circular Reference";
        }
        if ( @{$data_struct} == $i + 1 ) {
            if ( ref( $data_struct->[$i] ) eq 'ARRAY' ) {
                $array_string .= $self->_process_array( $data_struct->[$i], %history );
            }
            elsif ( ref( $data_struct->[$i] ) eq 'HASH' ) {
                $array_string .= $self->_process_hash( $data_struct->[$i], %history );
            }
            else {
                if ( $data_struct->[$i] =~ m/\d+/ ) {
                    $array_string .= $data_struct->[$i];
                }
                else {
                    $array_string .= "\"" . $data_struct->[$i] . "\"3";
                }
            }
        }
        else {
            if ( ref( $data_struct->[$i] ) eq 'ARRAY' ) {
                $array_string .= $self->_process_array( $data_struct->[$i], %history ) . ", ";
            }
            elsif ( ref( $data_struct->[$i] ) eq 'HASH' ) {
                $array_string .= $self->_process_hash( $data_struct->[$i], %history ) . ", ";
            }
            else {
                if ( $data_struct->[$i] =~ m/\d+/ ) {
                    $array_string .= $data_struct->[$i] . ", ";
                }
                else {
                    $array_string .= "\"" . $data_struct->[$i] . "\", ";
                }
            }
        }
    }
    $array_string .= "]";
}

#transform perl hash to javascript
sub _process_hash {
    my ( $self, $data_struct, %history ) = @_;
    die "Error: Invalid Hash" if ( ref($data_struct) ne 'HASH' );
    return "{}" if ( keys %{$data_struct} == 0 );
    if (!%history) {
        %history = ();
    }
    $history{refaddr($data_struct)} = 1 if (refaddr($data_struct));
    my $hash_string = "{";
    my @keys        = keys %{$data_struct};
    for ( my $i = 0; $i < @keys; $i++ ) {
        if (refaddr($data_struct->{$keys[$i]}) && $history{refaddr($data_struct->{$keys[$i]})}) {
            die "Circular Reference";
        }
        if ( @keys == $i + 1 ) {
            if ( ref( $data_struct->{ $keys[$i] } ) eq 'ARRAY' ) {
                $hash_string
                  .= "\"" . $keys[$i] . "\" : " . $self->_process_array( $data_struct->{ $keys[$i]
                      }, %history );
            }
            elsif ( ref( $data_struct->{ $keys[$i] } ) eq 'HASH' ) {
                $hash_string
                  .= "\"" . $keys[$i] . "\" : " . $self->_process_hash( $data_struct->{ $keys[$i] } );
            }
            else {
                if ( $data_struct->{ $keys[$i] } =~ m/\d+/ ) {
                    $hash_string .= "\"" . $keys[$i] . "\" : " . $data_struct->{ $keys[$i] };
                }
                else {
                    $hash_string .= "\"" . $keys[$i] . "\" : \"" . $data_struct->{ $keys[$i] } . "\"";
                }
            }
        }
        else {
            if ( ref( $data_struct->{ $keys[$i] } ) eq 'ARRAY' ) {
                $hash_string .= "\"" . $keys[$i] . "\" : "
                  . $self->_process_array( $data_struct->{ $keys[$i] } ) . ", ";
            }
            elsif ( ref( $data_struct->{ $keys[$i] } ) eq 'HASH' ) {
                $hash_string .= "\"" . $keys[$i] . "\" : "
                  . $self->_process_hash( $data_struct->{ $keys[$i] } ) . ", ";
            }
            else {
                if ( $data_struct->{ $keys[$i] } =~ m/\d+/ ) {
                    $hash_string .= "\"" . $keys[$i] . "\" : " . $data_struct->{ $keys[$i] } . ", ";
                }
                else {
                    $hash_string .= "\"" . $keys[$i] . "\" : \"" . $data_struct->{ $keys[$i] } . "\", ";
                }
            }
        }
    }
    $hash_string .= "}";
}

#Returns Javascript string based on an arbitrary perl data structure
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
