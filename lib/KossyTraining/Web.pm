package KossyTraining::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use DBI;
use Digest::SHA;
use Time::Piece;
use Encode;
use DBIx::Skinny;
use KossyTraining::Model;

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ( $self, $c )  = @_;
        $c->stash->{site_name} = __PACKAGE__;
        $app->($self,$c);
    }
};

sub db {
    my $self = shift;
    if (! defined $self->{_db}) {
    $self->{_db} = KossyTraining::Model->new(+{
        dsn => 'dbi:mysql:dbname',
        username => 'your account',
        password => 'your password',
    });
    }
    return $self->{_db};
}

sub _decode {
    my ($self, $str, $code) = @_;
    $code //= 'utf-8';
    return Encode::decode($code, $str);
}

sub _encode {
    my ($self, $str, $code) = @_;
    $code //= 'utf-8';
    return Encode::encode($code, $str);
}

sub add_entry {
    my $self = shift;
    my ($body, $nickname) = @_;
    $body //= '';
    $nickname //= 'anonymous';
    my $object_id = substr(
        Digest::SHA::sha1_hex($$ . $self->_encode($body) . $self->_encode($nickname) . rand(1000)),
        0,
        16,
    );
    $self->db->insert('entry', {
        object_id  => $object_id,
        nickname   => $nickname,
        body       => $body,
        created_at => localtime->datetime(T => ' '),
    });
    return $object_id;
}

get '/' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    my @entries = $self->db->search('entry', {}, {
        order_by => { 'created_at' => 'DESC'}, });
    $c->render('index.tx', { entries => \@entries });
};

get '/about' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    $c->render('about.tx', { });
};

get '/contact' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    $c->render('contact.tx', { });
};

post '/create' => sub {
    my ($self, $c) = @_;
    my $result = $c->req->validator([
        'body' => {
            rule => [
                ['NOT_NULL', 'empty body'],
            ],
        },
        'nickname' => {
            default => 'anonymous',
            rule => [
                ['NOT_NULL', 'empty nickname'],
            ],
        }
    ]);
    if ($result->has_error) {
        return $c->render('index.tx', { error => 1, messages => $result->errors });
    }
    my $object_id = $self->add_entry(map { $result->valid($_) } qw/body nickname/);
    return $c->redirect('/');
};


1;

