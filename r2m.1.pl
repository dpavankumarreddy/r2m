use R2M;

my $qq = {
    
    #  Emitter is either 
    #    emitter => new R2M::MongoDB({ db => "r2m"})
    #  or
    #    emitter => new R2M::JSON({ basedir =>"/tmp" })
    #
    #  Use R2M::MongoDB to ETL directly from source DBI to MongoDB.
    #  If you use R2M::MongoDB, you need to have the MongoDB perl driver.
    #  Optional params in <angle brackets> with defaults shown unless (none)
    #    emitter => new R2M::MongoDB({
    #      db => "r2m"          NOT optional
    #      <host => "localhost">,
    #      <port => 27017>
    #      <username => (none)>
    #      <password => (none)>
    #      })
    #
    #  Alternatively, if you have very specific client connection settings,
    #  use the client field to identify a MongoDB::MongoClient() object that
    #  you create yourself:
    #    my $mc = MongoDB::MongoClient->new(various exotic args);
    #    emitter => new R2M::MongoDB({
    #      db => "r2m"          NOT optional
    #      client => $mc
    #  Presence of the client field supercedes all other args (except db).
    #  See https://metacpan.org/pod/MongoDB::MongoClient#ATTRIBUTES for an
    #  example of some of those exotic args.
    #
    #
    #  
    #  Use R2M::JSON to extract from source DBI to JSON files.
    #  If you use R2M::JSON, you do NOT need the MongoDB perl driver installed
    #  because all the MongoDB-specific bits are conditionally loaded at runtime.
    #  No other non-standard dependencies exist so you can use R2M "anywhere."
    #  You only need to ensure that your choice of DBD/DBI modules can be found.
    #  R2M::JSON will emit each collection in the spec into the basedir as
    #      $basedir/collectionname.json
    #  The JSON is CR-delimited (non-pretty) and will contain MongoDB type
    #  metadata conventions, e.g. Dates will be emitted thusly:
    #      { "myDate": {"$date","2014-02-02T00:00:00.000Z"} }
    #  
    #
    #  TBD:
    #  Roll your own:  emitter needs to create a class that supports two
    #  methods:
    #    collObject getColl(String collectionName).
    #    void close();
    #  The collObject in turn must support one method:  insert(hashRef)
    #
        emitter => new R2M::MongoDB({
          host =>"localhost",
          port => 27017,
          db => "r2m"}),

    #  We can "hide" the other emitter here by giving it a name that is
    #  not recognized by R2M.  Switch between this emitter (JSON) and
    #  and the MongoDB emitter for experimentation.
	XXemitter => new R2M::JSON({ basedir =>"/tmp" }),

    rdbs => {
	#  Each DB connection gets a handle name; D1 is just fine.
	#  Create as many as needed.
	#  Note: R2M does NOT join directly across DBs so have no fear;
	#  put as many as needed here:
	D1 => {
	    #  Connect using DBI params!
	    conn => "DBI:Pg:dbname=mydb;host=localhost",
	    user => "postgres",
	    pw => "postgres",
	    args => { AutoCommit => 0 },

	    #  For R2M debugging purposes; not used by DBI
	    alias => "a nice PG DB"
	}
    },

    tables => {
	# Each table is named and linked to the source DB where it 
	# can be found.  "contact" is the table name and it can be found
	# in database D1 described above:
	contact => {
	    db => "D1"
	}
    },


    collections => {
	#  The heart of the matter.
	#  One or more named target collections will be populated from source
	#  tables.  The model is "pull into mongoDB from RDBMS" rather than
	#  "push into mongoDB from RDBMS" because mongoDB has a richer target
	#  type system (nested structs, arrays, etc.)
      contacts => {
	  # This is the name as it is declared in the tables section above
	tblsrc => "contact",   

	# In the simplest use case, Each key in {flds} is a target field in the
	# mongoDB collection, and the value names the column in the table named
	# above in "src".
	# Target fields for mongoDB are (of course) CASE SENSITIVE.
	# Case sensitivity for source fields for RDBMS is ... ambiguous.  Because
	# so is SQL and individual RDBMS engine handling...
	# Basic types are handled correctly, e.g. dates end up as mongoDB dates.
	#
        # ALSO:  fixed length fields (e.g. char(64)) are rtrimmed!
	# 
	flds => {
	    firstname => "FNAME"
		, blob => "BLOB"
		, lastName => "LNAME"
		, hdate => "HIREDATE"
		, amt1 => "AMT1"
		, amt2 => "AMT2"
		, lastevent => "lastevent"
		, localevent => "localevent"
	}
      }
    }
};


#  Still thinking about exactly how to set this up...
my $ctx = new R2M();
$ctx->run($qq); 
