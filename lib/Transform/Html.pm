package Transform::Html;
use Exporter qw(import);
use HTML::Tidy;    #sudo apt-get install libhtml-tidy-perl
use Scalar::Util qw(refaddr);
 
our @EXPORT_OK = qw(transform);

sub new {
    my $self = {};
    bless $self;
    return $self;
}

sub _loop_hash {
  my ( $self, $data_struct, %history ) = @_;
  $history{refaddr($data_struct)} = 1 if (refaddr($data_struct));
  my @keys        = keys %{$data_struct};
  my $hash_string = "";
    for ( my $i = 0; $i < @keys; $i++ ) {
        if (refaddr($data_struct->{$keys[$i]}) && $history{refaddr($data_struct->{$keys[$i]})}) {
            die "Circular Reference";
        }
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
              . $self->_loop_hash( $data_struct->{ $keys[$i] } ) . "</dd>";
        }
        else {
            $hash_string
              .= '<dt>' . $keys[$i] . "</dt><dd>" . $data_struct->{ $keys[$i] } . "</dd>";
        }
    }
  return $hash_string;
}

#transform perl hash to html
sub _process_hash {
    my ( $self, $data_struct, %history ) = @_;
    die "Error: Invalid Hash" if ( ref($data_struct) ne 'HASH' );
    %history = () if (!%history);
    $history{refaddr($data_struct)} = 1 if (refaddr($data_struct));
    return "<dl>" . $self->_loop_hash($data_struct) . "</dl>";
}

sub _loop_array {
  my ( $self, $data_struct, %history ) = @_;
  $history{refaddr($data_struct)} = 1 if (refaddr($data_struct));
  my $array_string = "";
    for ( my $i = 0; $i < @{$data_struct}; $i++ ) {
        if (refaddr($data_struct->[$i]) && exists $history{refaddr($data_struct->[$i])}) {
            die "Circular Reference";
        }
        if ( ref( $data_struct->[$i] ) eq 'ARRAY' ) {
            $array_string .= $self->_loop_array( $data_struct->[$i] );
        }
        elsif ( ref( $data_struct->[$i] ) eq 'HASH' ) {
            $array_string .= '<li>' . $self->_process_hash( $data_struct->[$i] ) . "</li>";
        }
        else {
            $array_string .= '<li>' . $data_struct->[$i] . "</li>";
        }
    }
  return $array_string;
}

#transform perl array to html
sub _process_array {
    my ( $self, $data_struct, %history ) = @_;
    die "Error: Invalid Array" if ( ref($data_struct) ne 'ARRAY' );
    %history = () if (!%history);
    $history{refaddr($data_struct)} = 1 if (refaddr($data_struct));
    return "<ol>" . $self->_loop_array($data_struct) . "</ol>";
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
