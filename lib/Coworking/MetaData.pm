use strict;
use utf8;
package Coworking::MetaData;
use Mo qw'builder default xxx';

use YAML::XS ':all';
use Text::CSV::Slurp;

has metadata => (builder => 'get_metadata');
has metadata_file => ();
has spreadsheet_file => ();
has yaml_file => ();
has input => ();
has meta_map => (default => sub{+{}});
has input_map => (default => sub{+{}});

sub open {
    my $self = shift;
    if (my $spreadsheet_file = $self->spreadsheet_file) {
        my @input = map $self->reformat($_),
            @{Text::CSV::Slurp->load(file => $spreadsheet_file)};
        $self->input(\@input);
    }
    elsif (my $yaml = $self->yaml_file) {
        die 'yaml_file not yet supported';
    }
    else {
        die "'spreadsheet' or 'yaml_file' required";
    }
}

sub update {
    my $self = shift;
    $self->metadata;
    for my $data (@{$self->input}) {
        my $id = $data->{Name};
        my $idx = $self->meta_map->{$id};
        if (not defined $idx) {
            push @{$self->metadata}, $data;
        }
        else {
            $self->metadata->[$idx] = $data;
        }
    }
}

sub store {
    my $self = shift;
    DumpFile($self->metadata_file, $self->metadata);
}

sub get_metadata {
    my $self = shift;
    die "'metadata_file' required" unless $self->metadata_file;
    my $metadata = LoadFile($self->metadata_file);
    die unless ref($metadata) eq 'ARRAY';
    my $i = 0;
    for my $hash (@$metadata) {
        my $name = $hash->{Name} or XXX $hash;
        $self->meta_map->{$name} = $i++;
    }
    $self->meta_map;
    return $metadata;
}

sub reformat {
    my $self = shift;
    my $hash = shift;
    my $data = {};
    for my $Key (keys %{$self->spreadsheet_rules}) {
        my $key = $self->spreadsheet_rules->{$Key};
        XXX([$Key, $hash]) unless exists $hash->{$Key};
        my $value = $hash->{$Key};
        next unless defined $value;
        $value =~ s/^\s*(.*?)\s*$/$1/s;
        if (length($value)) {
            if ($key =~ /^(\w+)$/) {
                $data->{$1} = $value;
            }
            elsif ($key =~ /^(\w+)\.(\d)$/) {
                $data->{$1}[$2] = $value;
            }
            elsif ($key =~ /^(\w+)\.(\w+)$/) {
                $data->{$1}{$2} = $value;
            }
            elsif ($key =~ /^(\w+)\.(\w+)\.(\w+)$/) {
                $data->{$1}{$2}{$3} = $value;
            }
            else {
                die "Bad key: '$key'";
            }
        }
    }
    if (exists $data->{address}) {
        $data->{address} = [ map { $_ || '.' } @{$data->{address}} ];
    }
    if (exists $data->{URL}) {
        my $url = $data->{URL};
        # warn $url if $url =~ /\s/ or $url !~ /\w\.\w/;
        $url = "http://$url" unless $url =~ m!^https?://!;
        die "'$url'" unless $url =~ m!^https?://\w!;
        $data->{URL} = $url;
    }
    $self->assert_name($data);
    $self->input_map->{$data->{Name}} = $data;
    return $data;
}

sub assert_name {
    my $self = shift;
    my $data = shift;
    return if $data->{Name} and not $self->input_map->{$data->{Name}};
    my $name = $data->{URL} or XXX($data);
    die $name if $name =~ /\s/;
    $name =~ s!^https?://!!;
    $name =~ s!/$!!;
    die $name unless $name =~ /\w\.\w/;
    XXX($data) if $self->input_map->{$name};
    $data->{Name} = $name;
    $self->input_map->{$name} = $data;
}

has spreadsheet_rules => (default => sub {Load <<'...'});
Name: Name
Website: URL
Bio (150-word or less): _Bio

Address Line 1: address.0
Address Line 2: address.1
Address Line 3: address.2
City: address.3
State/Province: address.4
ZIP/Post Code: address.5
Country: address.6

Email Address: contact.email
Fax Number: contact.fax
Phone number: contact.phone

Latitude: geo.lat
Longitude: geo.long

Facebook page: info.facebook
Link to logo (photo only): info.logo
Link to Google Places page: info.places
Twitter handle: info.twitter
Link to Yelp page: info.yelp

Free drop-in? (y/n): pay.dropin.free
Drop-in day rate ($): pay.dropin.rate
Drop-in comments: pay.dropin.comment
Coworking Visa Accepted? (y/n): pay.visa
...

1;
