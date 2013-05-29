use Test::More 'no_plan';

use FindBin;
use utf8;
use lib "$FindBin::Bin/../mojo/lib";
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../extlib/lib/perl5";
use Encode qw/encode decode/;

use Test::Mojo;

# Test DB
$ENV{GITPREP_DB_FILE} = "$FindBin::Bin/basic.db";

# Test Repository home
$ENV{GITPREP_REP_HOME} = "$FindBin::Bin/../../gitprep_t_rep_home";

use Gitprep;

my $app = Gitprep->new;
my $t = Test::Mojo->new($app);

my $user = 'kimoto';
my $project = 'gitprep_t';

# For perl 5.8
{
  no warnings 'redefine';
  sub note { print STDERR "# $_[0]\n" unless $ENV{HARNESS_ACTIVE} }
}

note 'Home page';
{
  # Page access
  $t->get_ok('/');
  
  # Title
  $t->content_like(qr/GitPrep/);
  $t->content_like(qr/Users/);
  
  # User link
  $t->content_like(qr#/$user#);
}

note 'Projects page';
{
  # Page access
  $t->get_ok("/$user");
  
  # Title
  $t->content_like(qr/Repositories/);
  
  # project link
  $t->content_like(qr#/$user/$project#);
}

note 'Project page';
{
  # Page access
  $t->get_ok("/$user/$project");
  
  # Description
  $t->content_like(qr/gitprep test repository/);
  
  # Commit datetime
  $t->content_like(qr/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/);
  
  # README
  $t->content_like(qr/README/);
  
  # tree directory link
  $t->content_like(qr#/$user/$project/tree/master/dir#);

  # tree file link
  $t->content_like(qr#/$user/$project/blob/master/README#);
}

note 'Commit page';
{
  {
    # Page access
    $t->get_ok("/$user/$project/commit/4b0e81c462088b16fefbe545e00b993fd7e6f884");
    
    # Commit message
    $t->content_like(qr/first commit/);
    
    # Commit datetime
    $t->content_like(qr/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/);
    
    # Parent not eixsts
    $t->content_like(qr/0 <span .*?>parent/);
    
    # Commit id
    $t->content_like(qr/4b0e81c462088b16fefbe545e00b993fd7e6f884/);
    
    # Author
    $t->content_like(qr/Yuki Kimoto/);
    
    # File change count
    $t->content_like(qr/1 changed files/);
    
    # Added README
    $t->content_like(qr/class="file-add".*?README/s);
    
    # Empty file is added
    $t->content_like(qr/No changes/);
  }
  {
    # Page access (branch name)
    $t->get_ok("/$user/$project/commit/b1");
    $t->content_like(qr/\+bbb/);
  }
  {
    # Page access (branch name long)
    $t->get_ok("/$user/$project/commit/refs/heads/b1");
    $t->content_like(qr/\+bbb/);
    $t->content_like(qr#refs/heads/b1#);
  }
}

note 'Commits page';
{
  {
    # Page access
    $t->get_ok("/$user/$project/commits/master");
    $t->content_like(qr/Commit History/);
    
    # Commit date time
    $t->content_like(qr/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/);
  }
  {
    # Page access(branch name long)
    $t->get_ok("/$user/$project/commits/refs/heads/master");
    $t->content_like(qr#refs/heads/master#);
  }
}

note 'History page';
{
  {
    # Page access
    $t->get_ok("/$user/$project/commits/b1/README");
    $t->content_like(qr/History for/);
    
    # Content
    $t->content_like(qr/first commit/);
  }
  {
    # Page access (branch name long)
    $t->get_ok("/$user/$project/commits/refs/heads/b1/README");
    
    # Content
    $t->content_like(qr/first commit/);
  }
}

note 'Tags page';
{
  # Page access
  $t->get_ok("/$user/$project/tags");
  
  # Commit datetime
  $t->content_like(qr/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/);
  
  # Tree link
  $t->content_like(qr#/$user/$project/tree/t1#);
  
  # Commit link
  $t->content_like(qr#/$user/$project/commit/15ea9d711617abda5eed7b4173a3349d30bca959#);

  # Zip link
  $t->content_like(qr#/$user/$project/archive/t1.zip#);
  
  # Tar.gz link
  $t->content_like(qr#/$user/$project/archive/t1.tar.gz#);
}

note 'Tree page';
{
  {
    # Page access (hash)
    $t->get_ok("/$user/$project/tree/e891266d8aeab864c8eb36b7115416710b2cdc2e");
    
    # Commit datetime
    $t->content_like(qr/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/);
    
    # README
    $t->content_like(qr/README.*bbb/s);
    
    # tree directory link
    $t->content_like(qr#/$user/$project/tree/e891266d8aeab864c8eb36b7115416710b2cdc2e/dir#);

    # tree file link
    $t->content_like(qr#/$user/$project/blob/e891266d8aeab864c8eb36b7115416710b2cdc2e/README#);
  }
  {
    # Page access (branch name)
    $t->get_ok("/$user/$project/tree/b21/dir");
    
    # File
    $t->content_like(qr/b\.txt/s);
  }
  {
    # Page access (branch name middle)
    $t->get_ok("/$user/$project/tree/heads/b21/dir");
    
    # File
    $t->content_like(qr/b\.txt/s);
  }
  {
    # Page access (branch name long)
    $t->get_ok("/$user/$project/tree/refs/heads/b21/dir");
    $t->content_like(qr#refs/heads/b21#);
    
    # File
    $t->content_like(qr/b\.txt/s);
  }
}

note 'Blob page';
{
  {
    # Page access (hash)
    $t->get_ok("/$user/$project/blob/b9f0f107672b910a44d22d4623ce7445d40565aa/a_renamed.txt");
    
    # Commit datetime
    $t->content_like(qr/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/);
    
    # Content
    $t->content_like(qr/あああ/);
  }
  {
    # Page access (branch name)
    $t->get_ok("/$user/$project/blob/b1/README");
    
    # Content
    $t->content_like(qr/bbb/);
  }
  {
    # Page access (branch name middle)
    $t->get_ok("/$user/$project/blob/heads/b1/README");
    
    # Content
    $t->content_like(qr/bbb/);
  }
  {
    # Page access (branch name long)
    $t->get_ok("/$user/$project/blob/refs/heads/b1/README");
    $t->content_like(qr#refs/heads/b1#);
    
    # Content
    $t->content_like(qr/bbb/);
  }}

note 'raw page';
{
  {
    # Page access (hash)
    $t->get_ok("/$user/$project/raw/b9f0f107672b910a44d22d4623ce7445d40565aa/a_renamed.txt");
    
    # Content
    my $content_binary = $t->tx->res->body;
    my $content = decode('UTF-8', $content_binary);
    like($content, qr/あああ/);
  }
  {
    # Page access (branch name)
    $t->get_ok("/$user/$project/raw/b21/dir/b.txt");
    
    my $content = $t->tx->res->body;
    like($content, qr/aaaa/);
  }
  {
    # Page access (branch name middle)
    $t->get_ok("/$user/$project/raw/heads/b21/dir/b.txt");
    
    my $content = $t->tx->res->body;
    like($content, qr/aaaa/);
  }
  {
    # Page access (branch name long)
    $t->get_ok("/$user/$project/raw/refs/heads/b21/dir/b.txt");
    
    my $content = $t->tx->res->body;
    like($content, qr/aaaa/);
  }
}

note 'Aarchive';
{
  # Archive zip
  $t->get_ok("/$user/$project/archive/t1.zip");
  $t->content_type_is('application/zip');
  
  # Archice tar.gz
  $t->get_ok("/$user/$project/archive/t1.tar.gz");
  $t->content_type_is('application/x-tar');
}

note 'Compare page';
{
  # Page access (branch name)
  $t->get_ok("/$user/$project/compare/b1...master");
  $t->content_like(qr#renamed dir/a\.txt to dir/b\.txt and added text#);

  # Page access (branch name long)
  $t->get_ok("/$user/$project/compare/refs/heads/b1...refs/heads/master");
  $t->content_like(qr#renamed dir/a\.txt to dir/b\.txt and added text#);

}

note 'API References';
{
  # Page access (branch name)
  $t->get_ok("/$user/$project/api/revs");
  my $content = $t->tx->res->body;
  like($content, qr/branch_names/);
  like($content, qr/tag_names/);
}

note 'Network page';
{
  # Page access
  $t->get_ok("/$user/$project/network");
  $t->content_like(qr/Network/);
}

note 'README';
{
  # Links
  $t->get_ok("/$user/$project/tree/84199670c2f8e51f87b05b336020bde968975498");
  $t->content_like(qr#<a href="http://foo1">http://foo1</a>#);
  $t->content_like(qr#<a href="https://foo2">https://foo2</a>#);
  $t->content_like(qr#<a href="http://foo3">http://foo3</a>#);
  $t->content_like(qr#<a href="http://foo4">http://foo4</a>#);
  $t->content_like(qr#<a href="http://foo5">http://foo5</a>#);
}

note 'Branches';
{
  # Page access
  $t->get_ok("/$user/$project/branches");
  $t->content_like(qr/Branches/);
  
  # No merged branch
  $t->content_like(qr/no-merged-branch.*?no_merged/s);
  
  # Marged branch
  $t->content_like(qr/"merged-branch.*?b2/s);
}

note 'Compare';
{
  # Page access
  $t->get_ok("/$user/$project/compare/master...no_merged");
  $t->content_like(qr/branch change/);
  $t->content_like(qr#http://foo5branch change#);
}
