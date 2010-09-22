use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/MouseX/Extend.pm';

requires 'Mouse' => 0.70;

test_requires 'Test::More' => 0.88; # done_testing()

tests_recursive 't', 't/*';
author_tests 'xt';

auto_set_repository() if -d '.git';

clean_files qw(
    MouseX-Extend-* *.stackdump
    cover_db
    nytprof
    *.out
);

WriteAll(check_nmake => 0);
