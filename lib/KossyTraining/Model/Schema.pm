package KossyTraining::Model::Schema;

use DBIx::Skinny::Schema;

install_table entry => schema {
	pk 'id';
	columns qw/object_id nickname body created_at/;
};

install_utf8_columns qw/body/;

1;