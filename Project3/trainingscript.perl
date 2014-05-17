#!/usr/bin/perl -w

use strict;
use Getopt::Long "GetOptions";
#use FindBin qw($RealBin);
my $RealBin = /apps/smt_tools/decoders/mosesdecoder/scripts/training/
use File::Spec::Functions;
use File::Spec::Unix;
use File::Basename;
BEGIN { require "$RealBin/LexicalTranslationModel.pm"; "LexicalTranslationModel"->import; }

# Train Factored Phrase Model
# (c) 2006-2009 Philipp Koehn
# with contributions from other JHU WS participants
# Train a model from a parallel corpus
# -----------------------------------------------------
$ENV{"LC_ALL"} = "C";
my $SCRIPTS_ROOTDIR = $RealBin;
if ($SCRIPTS_ROOTDIR eq '') {
    $SCRIPTS_ROOTDIR = dirname(__FILE__);
}
$SCRIPTS_ROOTDIR =~ s/\/training$//;
#$SCRIPTS_ROOTDIR = $ENV{"SCRIPTS_ROOTDIR"} if defined($ENV{"SCRIPTS_ROOTDIR"});

my($_EXTERNAL_BINDIR, $_ROOT_DIR, $_CORPUS_DIR, $_GIZA_E2F, $_GIZA_F2E, $_MODEL_DIR, $_TEMP_DIR, $_SORT_BUFFER_SIZE, $_SORT_BATCH_SIZE,  $_SORT_COMPRESS, $_SORT_PARALLEL, $_CORPUS,
   $_CORPUS_COMPRESSION, $_FIRST_STEP, $_LAST_STEP, $_F, $_E, $_MAX_PHRASE_LENGTH,
   $_LEXICAL_FILE, $_NO_LEXICAL_WEIGHTING, $_LEXICAL_COUNTS, $_VERBOSE, $_ALIGNMENT,
   $_ALIGNMENT_FILE, $_ALIGNMENT_STEM, @_LM, $_EXTRACT_FILE, $_GIZA_OPTION, $_HELP, $_PARTS,
   $_DIRECTION, $_ONLY_PRINT_GIZA, $_GIZA_EXTENSION, $_REORDERING,
   $_REORDERING_SMOOTH, $_INPUT_FACTOR_MAX, $_ALIGNMENT_FACTORS,
   $_TRANSLATION_FACTORS, $_REORDERING_FACTORS, $_GENERATION_FACTORS,
   $_DECODING_GRAPH_BACKOFF,
   $_DECODING_STEPS, $_PARALLEL, $_FACTOR_DELIMITER, @_PHRASE_TABLE,
   @_REORDERING_TABLE, @_GENERATION_TABLE, @_GENERATION_TYPE, $_GENERATION_CORPUS,
   $_DONT_ZIP,  $_MGIZA, $_MGIZA_CPUS, $_SNT2COOC, $_HMM_ALIGN, $_CONFIG, $_OSM, $_OSM_FACTORS, $_POST_DECODING_TRANSLIT,
   $_HIERARCHICAL,$_XML,$_SOURCE_SYNTAX,$_TARGET_SYNTAX,$_GLUE_GRAMMAR,$_GLUE_GRAMMAR_FILE,$_UNKNOWN_WORD_LABEL_FILE,$_GHKM,$_GHKM_TREE_FRAGMENTS,$_PCFG,@_EXTRACT_OPTIONS,@_SCORE_OPTIONS,
   $_ALT_DIRECT_RULE_SCORE_1, $_ALT_DIRECT_RULE_SCORE_2,
   $_OMIT_WORD_ALIGNMENT,$_FORCE_FACTORED_FILENAMES,
   $_MEMSCORE, $_FINAL_ALIGNMENT_MODEL,
   $_CONTINUE,$_MAX_LEXICAL_REORDERING,$_DO_STEPS,
   @_ADDITIONAL_INI,$_ADDITIONAL_INI_FILE,
   @_BASELINE_ALIGNMENT_MODEL, $_BASELINE_EXTRACT, $_BASELINE_ALIGNMENT,
   $_DICTIONARY, $_SPARSE_PHRASE_FEATURES, $_EPPEX, $_INSTANCE_WEIGHTS_FILE, $_LMODEL_OOV_FEATURE, $_NUM_LATTICE_FEATURES, $IGNORE, $_FLEXIBILITY_SCORE, $_EXTRACT_COMMAND);
my $_BASELINE_CORPUS = "";
my $_CORES = 1;
my $debug = 0; # debug this script, do not delete any files in debug mode

$_HELP = 1
    unless &GetOptions('root-dir=s' => \$_ROOT_DIR,
		       'external-bin-dir=s' => \$_EXTERNAL_BINDIR,
		       'corpus-dir=s' => \$_CORPUS_DIR,
		       'corpus=s' => \$_CORPUS,
		       'f=s' => \$_F,
		       'e=s' => \$_E,
		       'giza-e2f=s' => \$_GIZA_E2F,
		       'giza-f2e=s' => \$_GIZA_F2E,
		       'max-phrase-length=s' => \$_MAX_PHRASE_LENGTH,
		       'lexical-file=s' => \$_LEXICAL_FILE,
		       'no-lexical-weighting' => \$_NO_LEXICAL_WEIGHTING,
		       'write-lexical-counts' => \$_LEXICAL_COUNTS,
		       'model-dir=s' => \$_MODEL_DIR,
		       'temp-dir=s' => \$_TEMP_DIR,
		       'sort-buffer-size=s' => \$_SORT_BUFFER_SIZE,
		       'sort-batch-size=i' => \$_SORT_BATCH_SIZE,
		       'sort-compress=s' => \$_SORT_COMPRESS,
		       'sort-parallel=i' => \$_SORT_PARALLEL,
		       'extract-file=s' => \$_EXTRACT_FILE,
		       'alignment=s' => \$_ALIGNMENT,
		       'alignment-file=s' => \$_ALIGNMENT_FILE,
		       'alignment-stem=s' => \$_ALIGNMENT_STEM,
		       'verbose' => \$_VERBOSE,
		       'first-step=i' => \$_FIRST_STEP,
		       'last-step=i' => \$_LAST_STEP,
		       'giza-option=s' => \$_GIZA_OPTION,
		       'giza-extension=s' => \$_GIZA_EXTENSION,
		       'parallel' => \$_PARALLEL,
		       'lm=s' => \@_LM,
		       'help' => \$_HELP,
		       'mgiza' => \$_MGIZA, # multi-thread 
		       'mgiza-cpus=i' => \$_MGIZA_CPUS, # multi-thread 
		       'snt2cooc=s' => \$_SNT2COOC, # override snt2cooc exe. For when you want to run reduced memory snt2cooc.perl from mgiza
		       'hmm-align' => \$_HMM_ALIGN,
		       'final-alignment-model=s' => \$_FINAL_ALIGNMENT_MODEL, # use word alignment model 1/2/hmm/3/4/5 as final (default is 4); value 'hmm' equivalent to the --hmm-align switch
		       'debug' => \$debug,
		       'dont-zip' => \$_DONT_ZIP,
		       'parts=i' => \$_PARTS,
		       'direction=i' => \$_DIRECTION,
		       'only-print-giza' => \$_ONLY_PRINT_GIZA,
		       'reordering=s' => \$_REORDERING,
		       'reordering-smooth=s' => \$_REORDERING_SMOOTH,
		       'input-factor-max=i' => \$_INPUT_FACTOR_MAX,
		       'alignment-factors=s' => \$_ALIGNMENT_FACTORS,
		       'translation-factors=s' => \$_TRANSLATION_FACTORS,
		       'reordering-factors=s' => \$_REORDERING_FACTORS,
		       'generation-factors=s' => \$_GENERATION_FACTORS,
		       'decoding-steps=s' => \$_DECODING_STEPS,
		       'decoding-graph-backoff=s' => \$_DECODING_GRAPH_BACKOFF,
		       'bin-dir=s' => \$IGNORE,
		       'scripts-root-dir=s' => \$IGNORE,
		       'factor-delimiter=s' => \$_FACTOR_DELIMITER,
		       'phrase-translation-table=s' => \@_PHRASE_TABLE,
		       'generation-corpus=s' => \$_GENERATION_CORPUS,
		       'generation-table=s' => \@_GENERATION_TABLE,
		       'reordering-table=s' => \@_REORDERING_TABLE,
		       'generation-type=s' => \@_GENERATION_TYPE,
		       'continue' => \$_CONTINUE,
		       'hierarchical' => \$_HIERARCHICAL,
		       'glue-grammar' => \$_GLUE_GRAMMAR,
		       'glue-grammar-file=s' => \$_GLUE_GRAMMAR_FILE,
		       'unknown-word-label-file=s' => \$_UNKNOWN_WORD_LABEL_FILE,
		       'ghkm' => \$_GHKM,
		       'ghkm-tree-fragments' => \$_GHKM_TREE_FRAGMENTS,
		       'pcfg' => \$_PCFG,
		       'alt-direct-rule-score-1' => \$_ALT_DIRECT_RULE_SCORE_1,
		       'alt-direct-rule-score-2' => \$_ALT_DIRECT_RULE_SCORE_2,
		       'extract-options=s' => \@_EXTRACT_OPTIONS,
		       'score-options=s' => \@_SCORE_OPTIONS,
		       'source-syntax' => \$_SOURCE_SYNTAX,
		       'target-syntax' => \$_TARGET_SYNTAX,
		       'xml' => \$_XML,
		       'no-word-alignment' => \$_OMIT_WORD_ALIGNMENT,
		       'config=s' => \$_CONFIG,
		       'osm-model=s' => \$_OSM,
			'osm-setting=s' => \$_OSM_FACTORS,
			'post-decoding-translit=s' => \$_POST_DECODING_TRANSLIT,		
		       'max-lexical-reordering' => \$_MAX_LEXICAL_REORDERING,
		       'do-steps=s' => \$_DO_STEPS,
		       'memscore:s' => \$_MEMSCORE,
		       'force-factored-filenames' => \$_FORCE_FACTORED_FILENAMES,
		       'dictionary=s' => \$_DICTIONARY,
		       'sparse-phrase-features' => \$_SPARSE_PHRASE_FEATURES,
		       'eppex:s' => \$_EPPEX,
		       'additional-ini=s' => \@_ADDITIONAL_INI, 
		       'additional-ini-file=s' => \$_ADDITIONAL_INI_FILE, 
		       'baseline-alignment-model=s{8}' => \@_BASELINE_ALIGNMENT_MODEL,
		       'baseline-extract=s' => \$_BASELINE_EXTRACT,
		       'baseline-corpus=s' => \$_BASELINE_CORPUS,
		       'baseline-alignment=s' => \$_BASELINE_ALIGNMENT,
		       'cores=i' => \$_CORES,
		       'instance-weights-file=s' => \$_INSTANCE_WEIGHTS_FILE,
		       'lmodel-oov-feature' => \$_LMODEL_OOV_FEATURE,
		       'num-lattice-features=i' => \$_NUM_LATTICE_FEATURES,
		       'flexibility-score' => \$_FLEXIBILITY_SCORE,
		       'extract-command=s' => \$_EXTRACT_COMMAND,
               );

if ($_HELP) {
    print "Train Phrase Model

Steps: (--first-step to --last-step)
(1) prepare corpus
(2) run GIZA
(3) align words
(4) learn lexical translation
(5) extract phrases
(6) score phrases
(7) learn reordering model
(8) learn generation model
(9) create decoder config file

For more, please check manual or contact koehn\@inf.ed.ac.uk\n";
  exit(1);
}

if (defined($IGNORE)) {
  print STDERR "WARNING: Do not specify -bin-dir or -scripts-root-dir anymore. These variable are ignored and will be deleted soon";
}

# convert all paths to absolute paths
$_ROOT_DIR = File::Spec->rel2abs($_ROOT_DIR) if defined($_ROOT_DIR);
$_EXTERNAL_BINDIR = File::Spec->rel2abs($_EXTERNAL_BINDIR) if defined($_EXTERNAL_BINDIR);
$_CORPUS_DIR = File::Spec->rel2abs($_CORPUS_DIR) if defined($_CORPUS_DIR);
$_CORPUS = File::Spec->rel2abs($_CORPUS) if defined($_CORPUS);
$_LEXICAL_FILE = File::Spec->rel2abs($_LEXICAL_FILE) if defined($_LEXICAL_FILE);
$_MODEL_DIR = File::Spec->rel2abs($_MODEL_DIR) if defined($_MODEL_DIR);
$_TEMP_DIR = File::Spec->rel2abs($_TEMP_DIR) if defined($_TEMP_DIR);
$_ALIGNMENT_FILE = File::Spec->rel2abs($_ALIGNMENT_FILE) if defined($_ALIGNMENT_FILE);
$_ALIGNMENT_STEM = File::Spec->rel2abs($_ALIGNMENT_STEM) if defined($_ALIGNMENT_STEM);
$_GLUE_GRAMMAR_FILE = File::Spec->rel2abs($_GLUE_GRAMMAR_FILE) if defined($_GLUE_GRAMMAR_FILE);
$_UNKNOWN_WORD_LABEL_FILE = File::Spec->rel2abs($_UNKNOWN_WORD_LABEL_FILE) if defined($_UNKNOWN_WORD_LABEL_FILE);
$_EXTRACT_FILE = File::Spec->rel2abs($_EXTRACT_FILE) if defined($_EXTRACT_FILE);
foreach (@_PHRASE_TABLE) { $_ = File::Spec->rel2abs($_); }
foreach (@_REORDERING_TABLE) { $_ = File::Spec->rel2abs($_); }
foreach (@_GENERATION_TABLE) { $_ = File::Spec->rel2abs($_); }
$_GIZA_E2F = File::Spec->rel2abs($_GIZA_E2F) if defined($_GIZA_E2F);
$_GIZA_F2E = File::Spec->rel2abs($_GIZA_F2E) if defined($_GIZA_F2E);

my $_SCORE_OPTIONS; # allow multiple switches
foreach (@_SCORE_OPTIONS) { $_SCORE_OPTIONS .= $_." "; }
chop($_SCORE_OPTIONS) if $_SCORE_OPTIONS;
my $_EXTRACT_OPTIONS; # allow multiple switches
foreach (@_EXTRACT_OPTIONS) { $_EXTRACT_OPTIONS .= $_." "; }
chop($_EXTRACT_OPTIONS) if $_EXTRACT_OPTIONS;
my $_ADDITIONAL_INI; # allow multiple switches
foreach (@_ADDITIONAL_INI) { $_ADDITIONAL_INI .= $_." "; }
chop($_ADDITIONAL_INI) if $_ADDITIONAL_INI;

$_HIERARCHICAL = 1 if $_SOURCE_SYNTAX || $_TARGET_SYNTAX;
$_XML = 1 if $_SOURCE_SYNTAX || $_TARGET_SYNTAX;
my $___FACTOR_DELIMITER = $_FACTOR_DELIMITER;
$___FACTOR_DELIMITER = '|' unless ($_FACTOR_DELIMITER);

print STDERR "Using SCRIPTS_ROOTDIR: $SCRIPTS_ROOTDIR\n";

# Setting the steps to perform
my $___VERBOSE = 0;
my $___FIRST_STEP = 1;
my $___LAST_STEP = 9;
$___VERBOSE = $_VERBOSE if $_VERBOSE;
$___FIRST_STEP = $_FIRST_STEP if $_FIRST_STEP;
$___LAST_STEP =  $_LAST_STEP  if $_LAST_STEP;
my $___DO_STEPS = $___FIRST_STEP."-".$___LAST_STEP;
$___DO_STEPS = $_DO_STEPS if $_DO_STEPS;
my @STEPS = (0,0,0,0,0,0,0,0,0);

my @step_conf = split(',',$___DO_STEPS);
my ($f,$l);
foreach my $step (@step_conf) {
  if ($step =~ /^(\d)$/) {
    $f = $1;
    $l = $1;
  }
  elsif ($step =~ /^(\d)-(\d)$/) {
    $f = $1;
    $l = $2;
  }
  else {
    die ("Malformed argument to --do-steps");
  }
  die("Only steps between 1 and 9 can be used") if ($f < 1 || $l > 9);
  die("The first step must be smaller than the last step") if ($f > $l);
	
  for (my $i=$f; $i<=$l; $i++) {
    $STEPS[$i] = 1;
  }
}


# supporting binaries from other packages
my $MKCLS = "$_EXTERNAL_BINDIR/mkcls";
my $MGIZA_MERGE_ALIGN = "$_EXTERNAL_BINDIR/merge_alignment.py";
my $GIZA;
my $SNT2COOC;

if ($STEPS[1] || $STEPS[2])
{	
	if(!defined $_MGIZA ){
		$GIZA = "$_EXTERNAL_BINDIR/GIZA++";
		if (-x "$_EXTERNAL_BINDIR/snt2cooc.out") {
			$SNT2COOC = "$_EXTERNAL_BINDIR/snt2cooc.out";
		} elsif (-x "$_EXTERNAL_BINDIR/snt2cooc") { # Since "snt2cooc.out" and "snt2cooc" work the same   
			$SNT2COOC = "$_EXTERNAL_BINDIR/snt2cooc";
		}
		print STDERR "Using single-thread GIZA\n";
	} else {
	        # accept either "mgiza" or "mgizapp" and either "snt2cooc.out" or "snt2cooc"
	        if (-x "$_EXTERNAL_BINDIR/mgiza") {
		        $GIZA = "$_EXTERNAL_BINDIR/mgiza";
 	        } elsif (-x "$_EXTERNAL_BINDIR/mgizapp") {
		        $GIZA = "$_EXTERNAL_BINDIR/mgizapp";
	        }
		if (-x "$_EXTERNAL_BINDIR/snt2cooc") {
			$SNT2COOC = "$_EXTERNAL_BINDIR/snt2cooc";
		} elsif (-x "$_EXTERNAL_BINDIR/snt2cooc.out") { # Important for users that use MGIZA and copy only the "mgiza" file to $_EXTERNAL_BINDIR
			$SNT2COOC = "$_EXTERNAL_BINDIR/snt2cooc.out";
		}
		print STDERR "Using multi-thread GIZA\n";	
		if (!defined($_MGIZA_CPUS)) {
			$_MGIZA_CPUS=4;
		}
		die("ERROR: Cannot find $MGIZA_MERGE_ALIGN") unless (-x $MGIZA_MERGE_ALIGN);
	}
	
	# override
	$SNT2COOC = "$_EXTERNAL_BINDIR/$_SNT2COOC" if defined($_SNT2COOC);	
}

# parallel extract
my $SPLIT_EXEC = `gsplit --help 2>/dev/null`; 
if($SPLIT_EXEC) {
  $SPLIT_EXEC = 'gsplit';
}
else {
  $SPLIT_EXEC = 'split';
}

my $SORT_EXEC = `gsort --help 2>/dev/null`; 
if($SORT_EXEC) {
  $SORT_EXEC = 'gsort';
}
else {
  $SORT_EXEC = 'sort';
}

my $__SORT_BUFFER_SIZE = "";
$__SORT_BUFFER_SIZE = "-S $_SORT_BUFFER_SIZE" if $_SORT_BUFFER_SIZE;

my $__SORT_BATCH_SIZE = "";
$__SORT_BATCH_SIZE = "--batch-size $_SORT_BATCH_SIZE" if $_SORT_BATCH_SIZE;

my $__SORT_COMPRESS = "";
$__SORT_COMPRESS = "--compress-program $_SORT_COMPRESS" if $_SORT_COMPRESS;

my $__SORT_PARALLEL = "";
$__SORT_PARALLEL = "--parallel $_SORT_PARALLEL" if $_SORT_PARALLEL;

# supporting scripts/binaries from this package
my $PHRASE_EXTRACT;
if (defined($_EXTRACT_COMMAND)) {
  $PHRASE_EXTRACT = "$SCRIPTS_ROOTDIR/../bin/$_EXTRACT_COMMAND";
}
else {
  $PHRASE_EXTRACT = "$SCRIPTS_ROOTDIR/../bin/extract";
}
$PHRASE_EXTRACT = "$SCRIPTS_ROOTDIR/generic/extract-parallel.perl $_CORES $SPLIT_EXEC \"$SORT_EXEC $__SORT_BUFFER_SIZE $__SORT_BATCH_SIZE $__SORT_COMPRESS $__SORT_PARALLEL\" $PHRASE_EXTRACT";

my $RULE_EXTRACT;
if (defined($_EXTRACT_COMMAND)) {
  $RULE_EXTRACT = "$SCRIPTS_ROOTDIR/../bin/$_EXTRACT_COMMAND";
}
elsif (defined($_GHKM)) {
  $RULE_EXTRACT = "$SCRIPTS_ROOTDIR/../bin/extract-ghkm";
}
else {
  $RULE_EXTRACT = "$SCRIPTS_ROOTDIR/../bin/extract-rules";
}
$RULE_EXTRACT = "$SCRIPTS_ROOTDIR/generic/extract-parallel.perl $_CORES $SPLIT_EXEC \"$SORT_EXEC $__SORT_BUFFER_SIZE $__SORT_BATCH_SIZE $__SORT_COMPRESS $__SORT_PARALLEL\" $RULE_EXTRACT";

my $LEXICAL_REO_SCORER = "$SCRIPTS_ROOTDIR/../bin/lexical-reordering-score";
my $MEMSCORE = "$SCRIPTS_ROOTDIR/../bin/memscore";
my $EPPEX = "$SCRIPTS_ROOTDIR/../bin/eppex";
my $SYMAL = "$SCRIPTS_ROOTDIR/../bin/symal";
my $GIZA2BAL = "$SCRIPTS_ROOTDIR/training/giza2bal.pl";

my $PHRASE_SCORE = "$SCRIPTS_ROOTDIR/../bin/score";
$PHRASE_SCORE = "$SCRIPTS_ROOTDIR/generic/score-parallel.perl $_CORES \"$SORT_EXEC $__SORT_BUFFER_SIZE $__SORT_BATCH_SIZE $__SORT_COMPRESS $__SORT_PARALLEL\" $PHRASE_SCORE";

my $PHRASE_CONSOLIDATE = "$SCRIPTS_ROOTDIR/../bin/consolidate";
my $FLEX_SCORER = "$SCRIPTS_ROOTDIR/training/flexibility_score.py";

# utilities
my $ZCAT = "gzip -cd";
my $BZCAT = "bzcat";

# do a sanity check to make sure we can find the necessary binaries since
# these are not installed by default
# not needed if we start after step 2
die("ERROR: Cannot find mkcls, GIZA++/mgiza, & snt2cooc.out/snt2cooc in $_EXTERNAL_BINDIR.\nYou MUST specify the parameter -external-bin-dir") unless ((!$STEPS[2]) ||
                                       (defined($_EXTERNAL_BINDIR) && -x $GIZA && defined($SNT2COOC) && -x $MKCLS));

# set varibles to defaults or from options
my $___ROOT_DIR = ".";
$___ROOT_DIR = $_ROOT_DIR if $_ROOT_DIR;
my $___CORPUS_DIR  = $___ROOT_DIR."/corpus";
$___CORPUS_DIR = $_CORPUS_DIR if $_CORPUS_DIR;
die("ERROR: use --corpus to specify corpus") unless $_CORPUS || !($STEPS[1] || $STEPS[4] || $STEPS[5] || $STEPS[8]);
my $___CORPUS      = $_CORPUS;

# check the final-alignment-model switch
my $___FINAL_ALIGNMENT_MODEL = undef;
$___FINAL_ALIGNMENT_MODEL = 'hmm' if $_HMM_ALIGN;
$___FINAL_ALIGNMENT_MODEL = $_FINAL_ALIGNMENT_MODEL if $_FINAL_ALIGNMENT_MODEL;

die("ERROR: --final-alignment-model can be set to '1', '2', 'hmm', '3', '4' or '5'")
	unless (!defined($___FINAL_ALIGNMENT_MODEL) or $___FINAL_ALIGNMENT_MODEL =~ /^(1|2|hmm|3|4|5)$/);

my $___GIZA_EXTENSION = 'A3.final';
if(defined $___FINAL_ALIGNMENT_MODEL) {
    $___GIZA_EXTENSION = 'A1.5' if $___FINAL_ALIGNMENT_MODEL eq '1';
    $___GIZA_EXTENSION = 'A2.5' if $___FINAL_ALIGNMENT_MODEL eq '2';
    $___GIZA_EXTENSION = 'Ahmm.5' if $___FINAL_ALIGNMENT_MODEL eq 'hmm';
}
$___GIZA_EXTENSION = $_GIZA_EXTENSION if $_GIZA_EXTENSION;

my $___CORPUS_COMPRESSION = '';
if ($_CORPUS_COMPRESSION) {
  $___CORPUS_COMPRESSION = ".$_CORPUS_COMPRESSION";
}

# foreign/English language extension
die("ERROR: use --f to specify foreign language") unless $_F;
die("ERROR: use --e to specify English language") unless $_E;
my $___F = $_F;
my $___E = $_E;

# vocabulary files in corpus dir
my $___VCB_E = $___CORPUS_DIR."/".$___E.".vcb";
my $___VCB_F = $___CORPUS_DIR."/".$___F.".vcb";

# GIZA generated files
my $___GIZA = $___ROOT_DIR."/giza";
my $___GIZA_E2F = $___GIZA.".".$___E."-".$___F;
my $___GIZA_F2E = $___GIZA.".".$___F."-".$___E;
$___GIZA_E2F = $_GIZA_E2F if $_GIZA_E2F;
$___GIZA_F2E = $_GIZA_F2E if $_GIZA_F2E;
my $___GIZA_OPTION = "";
$___GIZA_OPTION = $_GIZA_OPTION if $_GIZA_OPTION;

# alignment heuristic
my $___ALIGNMENT = "grow-diag-final";
$___ALIGNMENT = $_ALIGNMENT if $_ALIGNMENT;
my $___NOTE_ALIGNMENT_DROPS = 1;

# baseline alignment model for incremetal updating
die "ERROR: buggy definition of baseline alignment model, should have 8 values:\n\t".join("\n\t",@_BASELINE_ALIGNMENT_MODEL)."\n"
  unless scalar(@_BASELINE_ALIGNMENT_MODEL) == 8 || scalar(@_BASELINE_ALIGNMENT_MODEL) == 0;
die "ERROR: use of baseline alignment model limited to HMM training (-hmm-align)\n"
  if defined($___FINAL_ALIGNMENT_MODEL) && $___FINAL_ALIGNMENT_MODEL ne 'hmm' && scalar(@_BASELINE_ALIGNMENT_MODEL) == 8;

# model dir and alignment/extract file
my $___MODEL_DIR = $___ROOT_DIR."/model";
$___MODEL_DIR = $_MODEL_DIR if $_MODEL_DIR;
my $___ALIGNMENT_FILE = "$___MODEL_DIR/aligned";
$___ALIGNMENT_FILE = $_ALIGNMENT_FILE if $_ALIGNMENT_FILE;
my $___ALIGNMENT_STEM = $___ALIGNMENT_FILE;
$___ALIGNMENT_STEM = $_ALIGNMENT_STEM if $_ALIGNMENT_STEM;
my $___EXTRACT_FILE = $___MODEL_DIR."/extract";
$___EXTRACT_FILE = $_EXTRACT_FILE if $_EXTRACT_FILE;
my $___GLUE_GRAMMAR_FILE = $___MODEL_DIR."/glue-grammar";
$___GLUE_GRAMMAR_FILE = $_GLUE_GRAMMAR_FILE if $_GLUE_GRAMMAR_FILE;

my $___CONFIG = $___MODEL_DIR."/moses.ini";
$___CONFIG = $_CONFIG if $_CONFIG;

my $___DONT_ZIP = 0; 
$_DONT_ZIP = $___DONT_ZIP unless $___DONT_ZIP;

my $___TEMP_DIR = $___MODEL_DIR;
$___TEMP_DIR = $_TEMP_DIR if $_TEMP_DIR;

my $___CONTINUE = 0; 
$___CONTINUE = $_CONTINUE if $_CONTINUE;

my $___MAX_PHRASE_LENGTH = "7";
$___MAX_PHRASE_LENGTH = "10" if $_HIERARCHICAL;

my $___LEXICAL_WEIGHTING = 1;
my $___LEXICAL_COUNTS = 0;
my $___LEXICAL_FILE = $___MODEL_DIR."/lex";
$___MAX_PHRASE_LENGTH = $_MAX_PHRASE_LENGTH if $_MAX_PHRASE_LENGTH;
$___LEXICAL_WEIGHTING = 0 if $_NO_LEXICAL_WEIGHTING;
$___LEXICAL_COUNTS = 1 if $_LEXICAL_COUNTS;
$___LEXICAL_FILE = $_LEXICAL_FILE if $_LEXICAL_FILE;

my $___PHRASE_SCORER = "phrase-extract";
$___PHRASE_SCORER = "memscore" if defined $_MEMSCORE;
my $___MEMSCORE_OPTIONS = "-s ml -s lexweights \$LEX_E2F -r ml -r lexweights \$LEX_F2E -s const 2.718";
$___MEMSCORE_OPTIONS = $_MEMSCORE if $_MEMSCORE;


my @___LM = ();
if ($STEPS[9]) {
  die "ERROR: use --lm factor:order:filename to specify at least one language model"
    if scalar @_LM == 0;
  foreach my $lm (@_LM) {
    my $type = 0; # default to srilm
    my ($f, $order, $filename);
    ($f, $order, $filename, $type) = split /:/, $lm, 4;
    die "ERROR: Wrong format of --lm. Expected: --lm factor:order:filename"
      if $f !~ /^[0-9,]+$/ || $order !~ /^[0-9]+$/ || !defined $filename;
    die "ERROR: Filename is not absolute: $filename"
      unless file_name_is_absolute $filename;
    die "ERROR: Language model file not found or empty: $filename"
      if ! -e $filename;
    push @___LM, [ $f, $order, $filename, $type ];
  }
}

my $___PARTS = 1;
$___PARTS = $_PARTS if $_PARTS;

my $___DIRECTION = 0;
$___DIRECTION = $_DIRECTION if $_DIRECTION;

# don't fork
my $___NOFORK = !defined $_PARALLEL;

my $___ONLY_PRINT_GIZA = 0;
$___ONLY_PRINT_GIZA = 1 if $_ONLY_PRINT_GIZA;

# Reordering model (esp. lexicalized)
my $___REORDERING = "distance";
$___REORDERING = $_REORDERING if $_REORDERING;
my $___REORDERING_SMOOTH = 0.5;
$___REORDERING_SMOOTH = $_REORDERING_SMOOTH if $_REORDERING_SMOOTH;
my @REORDERING_MODELS;
my $REORDERING_LEXICAL = 0; # flag for building lexicalized reordering models
my %REORDERING_MODEL_TYPES = ();

my $___MAX_LEXICAL_REORDERING = 0;
$___MAX_LEXICAL_REORDERING = 1 if $_MAX_LEXICAL_REORDERING;

my $model_num = 0;

foreach my $r (split(/\,/,$___REORDERING)) {

   #Don't do anything for distance models
   next if ($r eq "distance");

   #change some config string options, to be backward compatible
   $r =~ s/orientation/msd/;
   $r =~ s/unidirectional/backward/;
   #set default values
   push @REORDERING_MODELS, {};
   $REORDERING_MODELS[$model_num]{"dir"} = "backward";   
   $REORDERING_MODELS[$model_num]{"type"} = "wbe";
   $REORDERING_MODELS[$model_num]{"collapse"} = "allff";

   #handle the options set in the config string
   foreach my $reoconf (split(/\-/,$r)) {
      if ($reoconf =~ /^((msd)|(mslr)|(monotonicity)|(leftright))/) { 
        $REORDERING_MODELS[$model_num]{"orient"} = $reoconf;
        $REORDERING_LEXICAL = 1;
      }
      elsif ($reoconf =~ /^((bidirectional)|(backward)|(forward))/) {
        $REORDERING_MODELS[$model_num]{"dir"} = $reoconf;
      }
      elsif ($reoconf =~ /^((fe)|(f))/) {
        $REORDERING_MODELS[$model_num]{"lang"} = $reoconf;
      }
      elsif ($reoconf =~ /^((hier)|(phrase)|(wbe))/) {
        $REORDERING_MODELS[$model_num]{"type"} = $reoconf;
      }
      elsif ($reoconf =~ /^((collapseff)|(allff))/) {
        $REORDERING_MODELS[$model_num]{"collapse"} = $reoconf;
      }
      else {
        print STDERR "unknown type in reordering model config string: \"$reoconf\" in $r\n";
        exit(1);
      }
  }


  #check that the required attributes are given
  if (!defined($REORDERING_MODELS[$model_num]{"type"})) {
     print STDERR "you have to give the type of the reordering models (mslr, msd, monotonicity or leftright); it is not done in $r\n";
     exit(1);
  }

  if (!defined($REORDERING_MODELS[$model_num]{"lang"})) {
     print STDERR "you have specify which languages to condition on for lexical reordering (f or fe); it is not done in $r\n";
     exit(1);
  }

  #fix the all-string
  $REORDERING_MODELS[$model_num]{"filename"} = $REORDERING_MODELS[$model_num]{"type"}."-".$REORDERING_MODELS[$model_num]{"orient"}.'-'.
                                               $REORDERING_MODELS[$model_num]{"dir"}."-".$REORDERING_MODELS[$model_num]{"lang"};
  $REORDERING_MODELS[$model_num]{"config"} = $REORDERING_MODELS[$model_num]{"filename"}."-".$REORDERING_MODELS[$model_num]{"collapse"};

  # fix numfeatures
  $REORDERING_MODELS[$model_num]{"numfeatures"} = 1;
  $REORDERING_MODELS[$model_num]{"numfeatures"} = 2 if $REORDERING_MODELS[$model_num]{"dir"} eq "bidirectional";
  if ($REORDERING_MODELS[$model_num]{"collapse"} ne "collapseff") {
    if ($REORDERING_MODELS[$model_num]{"orient"} eq "msd") {
      $REORDERING_MODELS[$model_num]{"numfeatures"} *= 3;
    }
    elsif ($REORDERING_MODELS[$model_num]{"orient"} eq "mslr") {
      $REORDERING_MODELS[$model_num]{"numfeatures"} *= 4;
    }
    else {
      $REORDERING_MODELS[$model_num]{"numfeatures"} *= 2;
    }
  }

  # fix the overall model selection
  if (defined $REORDERING_MODEL_TYPES{$REORDERING_MODELS[$model_num]{"type"}}) {
     $REORDERING_MODEL_TYPES{$REORDERING_MODELS[$model_num]{"type"}} .=
        $REORDERING_MODELS[$model_num]{"orient"}."-"; 
  }
  else  {
     $REORDERING_MODEL_TYPES{$REORDERING_MODELS[$model_num]{"type"}} =
        $REORDERING_MODELS[$model_num]{"orient"};
  }
  $model_num++;
}

# pick the overall most specific model for each reordering model type
for my $mtype ( keys %REORDERING_MODEL_TYPES) {
  if ($REORDERING_MODEL_TYPES{$mtype} =~ /msd/) {
    $REORDERING_MODEL_TYPES{$mtype} = "msd"
  }
  elsif ($REORDERING_MODEL_TYPES{$mtype} =~ /monotonicity/) {
    $REORDERING_MODEL_TYPES{$mtype} = "monotonicity"
  }
  else {
    $REORDERING_MODEL_TYPES{$mtype} = "mslr"
  }
}

### Factored translation models
my $___NOT_FACTORED = !$_FORCE_FACTORED_FILENAMES;
$___NOT_FACTORED = 0 if $_INPUT_FACTOR_MAX;
my $___ALIGNMENT_FACTORS = "0-0";
$___ALIGNMENT_FACTORS = $_ALIGNMENT_FACTORS if defined($_ALIGNMENT_FACTORS);
die("ERROR: format for alignment factors is \"0-0\" or \"0,1,2-0,1\", you provided $___ALIGNMENT_FACTORS\n") if $___ALIGNMENT_FACTORS !~ /^\d+(\,\d+)*\-\d+(\,\d+)*$/;
$___NOT_FACTORED = 0 unless $___ALIGNMENT_FACTORS eq "0-0";

my $___TRANSLATION_FACTORS = undef;
$___TRANSLATION_FACTORS = "0-0" unless defined($_DECODING_STEPS); # single factor default
$___TRANSLATION_FACTORS = $_TRANSLATION_FACTORS if defined($_TRANSLATION_FACTORS);
die("ERROR: format for translation factors is \"0-0\" or \"0-0+1-1\" or \"0-0+0,1-0,1\", you provided $___TRANSLATION_FACTORS\n") 
  if defined $___TRANSLATION_FACTORS && $___TRANSLATION_FACTORS !~ /^\d+(\,\d+)*\-\d+(\,\d+)*(\+\d+(\,\d+)*\-\d+(\,\d+)*)*$/;
$___NOT_FACTORED = 0 unless $___TRANSLATION_FACTORS eq "0-0";

my $___REORDERING_FACTORS = undef;
$___REORDERING_FACTORS = "0-0" if defined($_REORDERING) && ! defined($_DECODING_STEPS); # single factor default
$___REORDERING_FACTORS = $_REORDERING_FACTORS if defined($_REORDERING_FACTORS);
die("ERROR: format for reordering factors is \"0-0\" or \"0-0+1-1\" or \"0-0+0,1-0,1\", you provided $___REORDERING_FACTORS\n") 
  if defined $___REORDERING_FACTORS && $___REORDERING_FACTORS !~ /^\d+(\,\d+)*\-\d+(\,\d+)*(\+\d+(\,\d+)*\-\d+(\,\d+)*)*$/;
$___NOT_FACTORED = 0 if defined($_REORDERING) && $___REORDERING_FACTORS ne "0-0";

my $___GENERATION_FACTORS = undef;
$___GENERATION_FACTORS = $_GENERATION_FACTORS if defined($_GENERATION_FACTORS);
die("ERROR: format for generation factors is \"0-1\" or \"0-1+0-2\" or \"0-1+0,1-1,2\", you provided $___GENERATION_FACTORS\n") 
  if defined $___GENERATION_FACTORS && $___GENERATION_FACTORS !~ /^\d+(\,\d+)*\-\d+(\,\d+)*(\+\d+(\,\d+)*\-\d+(\,\d+)*)*$/;
$___NOT_FACTORED = 0 if defined($___GENERATION_FACTORS);

my $___DECODING_STEPS = "t0";
$___DECODING_STEPS = $_DECODING_STEPS if defined($_DECODING_STEPS);
die("ERROR: format for decoding steps is \"t0,g0,t1,g1:t2\", you provided $___DECODING_STEPS\n") 
  if defined $_DECODING_STEPS && $_DECODING_STEPS !~ /^[tg]\d+([,:][tg]\d+)*$/;

### MAIN

&prepare()                 if $STEPS[1];
&run_giza()                if $STEPS[2];
&word_align()              if $STEPS[3];
&get_lexical_factored()    if $STEPS[4];
&extract_phrase_factored() if $STEPS[5];
&score_phrase_factored()   if $STEPS[6];
&get_reordering_factored() if $STEPS[7];
&get_generation_factored() if $STEPS[8];
&create_ini()              if $STEPS[9];

### (1) PREPARE CORPUS

sub prepare {
    print STDERR "(1) preparing corpus @ ".`date`;
    safesystem("mkdir -p $___CORPUS_DIR") or die("ERROR: could not create corpus dir $___CORPUS_DIR");
    
    print STDERR "(1.0) selecting factors @ ".`date`;
    my ($factor_f,$factor_e) = split(/\-/,$___ALIGNMENT_FACTORS);
    my $corpus = ($___NOT_FACTORED && !$_XML) ? $___CORPUS : $___CORPUS.".".$___ALIGNMENT_FACTORS;

    my $VCB_F, my $VCB_E;

    if ($___NOFORK) {
	if (! $___NOT_FACTORED || $_XML) {
	    &reduce_factors($___CORPUS.".".$___F,$corpus.".".$___F,$factor_f);
	    &reduce_factors($___CORPUS.".".$___E,$corpus.".".$___E,$factor_e);
	}
	
	&make_classes($corpus.".".$___F,$___VCB_F.".classes");
	&make_classes($corpus.".".$___E,$___VCB_E.".classes");
	
	$VCB_F = &get_vocabulary($corpus.".".$___F,$___VCB_F,0);
	$VCB_E = &get_vocabulary($corpus.".".$___E,$___VCB_E,1);
	
	&numberize_txt_file($VCB_F,$corpus.".".$___F,
			    $VCB_E,$corpus.".".$___E,
			    $___CORPUS_DIR."/$___F-$___E-int-train.snt");
	
	&numberize_txt_file($VCB_E,$corpus.".".$___E,
			    $VCB_F,$corpus.".".$___F,
			    $___CORPUS_DIR."/$___E-$___F-int-train.snt");
    } 
    else {
	print "Forking...\n";
	if (! $___NOT_FACTORED || $_XML) {
	    my $pid = fork();
	    die "ERROR: couldn't fork" unless defined $pid;
	    if (!$pid) {
		&reduce_factors($___CORPUS.".".$___F,$corpus.".".$___F,$factor_f);
		exit 0;
	    } 
	    else {
		&reduce_factors($___CORPUS.".".$___E,$corpus.".".$___E,$factor_e);
	    }
	    printf "Waiting for second reduce_factors process...\n";
	    waitpid($pid, 0);
	}
	my $pid = fork();
	die "ERROR: couldn't fork" unless defined $pid;
	if (!$pid) {
	    &make_classes($corpus.".".$___F,$___VCB_F.".classes");
	    exit 0;
	} # parent
	my $pid2 = fork();
	die "ERROR: couldn't fork again" unless defined $pid2;
	if (!$pid2) { #child
	    &make_classes($corpus.".".$___E,$___VCB_E.".classes");
	    exit 0;
	}
	
	$VCB_F = &get_vocabulary($corpus.".".$___F,$___VCB_F,0);
	$VCB_E = &get_vocabulary($corpus.".".$___E,$___VCB_E,1);
	
	&numberize_txt_file($VCB_F,$corpus.".".$___F,
			    $VCB_E,$corpus.".".$___E,
			    $___CORPUS_DIR."/$___F-$___E-int-train.snt");
	
	&numberize_txt_file($VCB_E,$corpus.".".$___E,
			    $VCB_F,$corpus.".".$___F,
			    $___CORPUS_DIR."/$___E-$___F-int-train.snt");
	printf "Waiting for mkcls processes to finish...\n";
	waitpid($pid2, 0);
	waitpid($pid, 0);
    }

	if (defined $_DICTIONARY)
	{
		my $dict= &make_dicts_files($_DICTIONARY, $VCB_F,$VCB_E,
                                    $___CORPUS_DIR."/gizadict.$___E-$___F",
                                    $___CORPUS_DIR."/gizadict.$___F-$___E");
		if (not $dict)
		{
			print STDERR "WARNING: empty dictionary\n";
			undef $_DICTIONARY;
		}
	}
}

sub reduce_factors {
    my ($full,$reduced,$factors) = @_;

    # my %INCLUDE;
    # foreach my $factor (split(/,/,$factors)) {
	# $INCLUDE{$factor} = 1;
    # }
    my @INCLUDE = sort {$a <=> $b} split(/,/,$factors);

    print STDERR "(1.0.5) reducing factors to produce $reduced  @ ".`date`;
    while(-e $reduced.".lock") {
	sleep(10);
    }
    if (-e $reduced) {
        print STDERR "  $reduced in place, reusing\n";
        return;
    }
    if (-e $reduced.".gz") {
        print STDERR "  $reduced.gz in place, reusing\n";
        return;
    }

    unless ($_XML) {
        # peek at input, to check if we are asked to produce exactly the
        # available factors
        my $inh = open_or_zcat($full);
        my $firstline = <$inh>;
        die "Corpus file $full is empty" unless $firstline;
        close $inh;
        # pick first word
        $firstline =~ s/^\s*//;
        $firstline =~ s/\s.*//;
        # count factors
        my $maxfactorindex = $firstline =~ tr/$___FACTOR_DELIMITER/$___FACTOR_DELIMITER/;
        if (join(",", @INCLUDE) eq join(",", 0..$maxfactorindex)) {
          # create just symlink; preserving compression
          my $realfull = $full;
          if (!-e $realfull && -e $realfull.".gz") {
            $realfull .= ".gz";
            $reduced =~ s/(\.gz)?$/.gz/;
          }
          safesystem("ln -s '$realfull' '$reduced'")
            or die "Failed to create symlink $realfull -> $reduced";
          return;
        }
    }

    # The default is to select the needed factors
    `touch $reduced.lock`;
    *IN = open_or_zcat($full);
    open(OUT,">".$reduced) or die "ERROR: Can't write $reduced";
    my $nr = 0;
    while(<IN>) {
        $nr++;
        print STDERR "." if $nr % 10000 == 0;
        print STDERR "($nr)" if $nr % 100000 == 0;
	s/<\S[^>]*>/ /g if $_XML; # remove xml
	chomp; s/ +/ /g; s/^ //; s/ $//;
	my $first = 1;
	foreach (split) {
	    my @FACTOR = split /\Q$___FACTOR_DELIMITER/;
              # \Q causes to disable metacharacters in regex
	    print OUT " " unless $first;
	    $first = 0;
	    my $first_factor = 1;
            foreach my $outfactor (@INCLUDE) {
              print OUT $___FACTOR_DELIMITER unless $first_factor;
              $first_factor = 0;
              my $out = $FACTOR[$outfactor];
              die "ERROR: Couldn't find factor $outfactor in token \"$_\" in $full LINE $nr" if !defined $out;
              print OUT $out;
            }
	    # for(my $factor=0;$factor<=$#FACTOR;$factor++) {
		# next unless defined($INCLUDE{$factor});
		# print OUT "|" unless $first_factor;
		# $first_factor = 0;
		# print OUT $FACTOR[$factor];
	    # }
	} 
	print OUT "\n";
    }
    print STDERR "\n";
    close(OUT);
    close(IN);
    `rm -f $reduced.lock`;
}

sub make_classes {
    my ($corpus,$classes) = @_;
    my $cmd = "$MKCLS -c50 -n2 -p$corpus -V$classes opt";
    print STDERR "(1.1) running mkcls  @ ".`date`."$cmd\n";
    if (-e $classes) {
        print STDERR "  $classes already in place, reusing\n";
        return;
    }
    safesystem("$cmd"); # ignoring the wrong exit code from mkcls (not dying)
}

sub get_vocabulary {
#    return unless $___LEXICAL_WEIGHTING;
    my($corpus,$vcb,$is_target) = @_;
    print STDERR "(1.2) creating vcb file $vcb @ ".`date`;
    
    my %WORD;
    open(TXT,$corpus) or die "ERROR: Can't read $corpus";
    while(<TXT>) {
	chop;
	foreach (split) { $WORD{$_}++; }
    }
    close(TXT);

    my ($id,%VCB);
    open(VCB,">", "$vcb") or die "ERROR: Can't write $vcb";

    # words from baseline alignment model when incrementally updating
    if (scalar @_BASELINE_ALIGNMENT_MODEL) {
      open(BASELINE_VCB,$_BASELINE_ALIGNMENT_MODEL[$is_target]);
      while(<BASELINE_VCB>) {
        chop;
        my ($i,$word,$count) = split;
	if (defined($WORD{$word})) {
          $count += $WORD{$word};
          delete($WORD{$word});
        }
	printf VCB "%d\t%s\t%d\n",$i,$word,$count;
	$VCB{$word} = $i;
        $id = $i+1;
      }
      close(BASELINE_VCB);
    }
    # not incrementally updating
    else {
      print VCB "1\tUNK\t0\n";
      $id=2;
    }

    my @NUM;
    foreach my $word (keys %WORD) {
	my $vcb_with_number = sprintf("%07d %s",$WORD{$word},$word);
	push @NUM,$vcb_with_number;
    }
    foreach (reverse sort @NUM) {
	my($count,$word) = split;
	printf VCB "%d\t%s\t%d\n",$id,$word,$count;
	$VCB{$word} = $id;
	$id++;
    }
    close(VCB);
    
    return \%VCB;
}

sub make_dicts_files {
    my ($dictfile,$VCB_SRC,$VCB_TGT,$outfile1, $outfile2) = @_;
    my %numberized_dict;
    print STDERR "(1.3) numberizing dictionaries $outfile1 and $outfile2 @ ".`date`;
    if ((-e $outfile1) && (-e $outfile2)) {
        print STDERR "  dictionary files already in place, reusing\n";
        return;
    }
    open(DICT,$dictfile) or die "ERROR: Can't read $dictfile";
	open(OUT1,">$outfile1") or die "ERROR: Can't write $outfile1";
	open(OUT2,">$outfile2") or die "ERROR: Can't write $outfile2";
    while(my $line = <DICT>) {
		my $src, my $tgt;
		($src, $tgt) = split(/\s+/,$line);
		chomp($tgt); chomp($src);
		if ((not defined($$VCB_TGT{$tgt})) || (not defined($$VCB_SRC{$src})))
		{
			print STDERR "Warning: unknown word in dictionary: $src <=> $tgt\n";
			next;
		}
		$numberized_dict{int($$VCB_TGT{$tgt})} = int($$VCB_SRC{$src}) ;
	}
    close(DICT);
	my @items = sort {$a <=> $b} keys %numberized_dict;
	if (scalar(@items) == 0) { return 0; } 
	foreach my $key (@items)
	{
		print OUT1 "$key $numberized_dict{$key}\n";
		print OUT2 "$numberized_dict{$key} $key\n";
	}
    close(OUT);
	return 1;
}


sub numberize_txt_file {
    my ($VCB_DE,$in_de,$VCB_EN,$in_en,$out) = @_;
    my %OUT;
    print STDERR "(1.3) numberizing corpus $out @ ".`date`;
    if (-e $out) {
        print STDERR "  $out already in place, reusing\n";
        return;
    }
    open(IN_DE,$in_de) or die "ERROR: Can't read $in_de";
    open(IN_EN,$in_en) or die "ERROR: Can't read $in_en";
    open(OUT,">$out") or die "ERROR: Can't write $out";
    while(my $de = <IN_DE>) {
	my $en = <IN_EN>;
	print OUT "1\n";
	print OUT &numberize_line($VCB_EN,$en);
	print OUT &numberize_line($VCB_DE,$de);
    }
    close(IN_DE);
    close(IN_EN);
    close(OUT);
}

sub numberize_line {
    my ($VCB,$txt) = @_;
    chomp($txt);
    my $out = "";
    my $not_first = 0;
    foreach (split(/ /,$txt)) { 
	next if $_ eq '';
	$out .= " " if $not_first++;
	print STDERR "Unknown word '$_'\n" unless defined($$VCB{$_});
	$out .= $$VCB{$_};
    }
    return $out."\n";
}

### (2) RUN GIZA

sub run_giza {
    return &run_giza_on_parts if $___PARTS>1;

    print STDERR "(2) running giza @ ".`date`;
    if ($___DIRECTION == 1 || $___DIRECTION == 2 || $___NOFORK) {
	&run_single_giza($___GIZA_F2E,$___E,$___F,
		     $___VCB_E,$___VCB_F,
		     $___CORPUS_DIR."/$___F-$___E-int-train.snt")
	    unless $___DIRECTION == 2;
	&run_single_giza($___GIZA_E2F,$___F,$___E,
		     $___VCB_F,$___VCB_E,
		     $___CORPUS_DIR."/$___E-$___F-int-train.snt")
	    unless $___DIRECTION == 1;
    } else {
	my $pid = fork();
	if (!defined $pid) {
	    die "ERROR: Failed to fork";
	}
	if (!$pid) { # i'm the child
	    &run_single_giza($___GIZA_F2E,$___E,$___F,
                     $___VCB_E,$___VCB_F,
                     $___CORPUS_DIR."/$___F-$___E-int-train.snt");
	    exit 0; # child exits
	} else { #i'm the parent
	    &run_single_giza($___GIZA_E2F,$___F,$___E,
                     $___VCB_F,$___VCB_E,
                     $___CORPUS_DIR."/$___E-$___F-int-train.snt");
	}
	printf "Waiting for second GIZA process...\n";
	waitpid($pid, 0);
    }
}

sub run_giza_on_parts {
    print STDERR "(2) running giza on $___PARTS cooc parts @ ".`date`;
    my $size = `cat $___CORPUS_DIR/$___F-$___E-int-train.snt | wc -l`;
    die "ERROR: Failed to get number of lines in $___CORPUS_DIR/$___F-$___E-int-train.snt"
      if $size == 0;
    
    if ($___DIRECTION == 1 || $___DIRECTION == 2 || $___NOFORK) {
	&run_single_giza_on_parts($___GIZA_F2E,$___E,$___F,
			      $___VCB_E,$___VCB_F,
			      $___CORPUS_DIR."/$___F-$___E-int-train.snt",$size)
   	    unless $___DIRECTION == 2;
 
	&run_single_giza_on_parts($___GIZA_E2F,$___F,$___E,
			      $___VCB_F,$___VCB_E,
			      $___CORPUS_DIR."/$___E-$___F-int-train.snt",$size)
   	    unless $___DIRECTION == 1;
    } else {
	my $pid = fork();
	if (!defined $pid) {
	    die "ERROR: Failed to fork";
	}
	if (!$pid) { # i'm the child
	    &run_single_giza_on_parts($___GIZA_F2E,$___E,$___F,
			      $___VCB_E,$___VCB_F,
			      $___CORPUS_DIR."/$___F-$___E-int-train.snt",$size);
	    exit 0; # child exits
	} else { #i'm the parent
	    &run_single_giza_on_parts($___GIZA_E2F,$___F,$___E,
			      $___VCB_F,$___VCB_E,
			      $___CORPUS_DIR."/$___E-$___F-int-train.snt",$size);
	}
	printf "Waiting for second GIZA process...\n";
	waitpid($pid, 0);
    }
}

sub run_single_giza_on_parts {
    my($dir,$e,$f,$vcb_e,$vcb_f,$train,$size) = @_;
    
    my $part = 0;

    # break up training data into parts
    open(SNT,$train) or die "ERROR: Can't read $train";
    { 
	my $i=0;
	while(<SNT>) {
	    $i++;
	    if ($i%3==1 && $part < ($___PARTS*$i)/$size && $part<$___PARTS) {
		close(PART) if $part;
		$part++;
		safesystem("mkdir -p $___CORPUS_DIR/part$part") or die("ERROR: could not create $___CORPUS_DIR/part$part");
		open(PART,">$___CORPUS_DIR/part$part/$f-$e-int-train.snt")
                   or die "ERROR: Can't write $___CORPUS_DIR/part$part/$f-$e-int-train.snt";
	    }
	    print PART $_;
	}
    }
    close(PART);
    close(SNT);

    # run snt2cooc in parts
    my @COOC_PART_FILE_NAME;
    for(my $i=1;$i<=$___PARTS;$i++) {
	&run_single_snt2cooc("$dir/part$i",$e,$f,$vcb_e,$vcb_f,"$___CORPUS_DIR/part$i/$f-$e-int-train.snt");
        push @COOC_PART_FILE_NAME, "$dir/part$i/$f-$e.cooc";
    }
    # include baseline cooc, if baseline alignment model (incremental training)
    if (scalar @_BASELINE_ALIGNMENT_MODEL) {
      push @COOC_PART_FILE_NAME, $_BASELINE_ALIGNMENT_MODEL[2 + ($dir eq $___GIZA_F2E?1:0)];
    }
    &merge_cooc_files($dir,$e,$f,@COOC_PART_FILE_NAME);

    # run giza
    &run_single_giza($dir,$e,$f,$vcb_e,$vcb_f,$train);
}

sub merge_cooc_files {
    my ($dir,$e,$f,@COOC_PART_FILE_NAME) = @_;

    # merge parts
    open(COOC,">$dir/$f-$e.cooc") or die "ERROR: Can't write $dir/$f-$e.cooc";
    my(@PF,@CURRENT);
    for(my $i=0;$i<scalar(@COOC_PART_FILE_NAME);$i++) {
	print STDERR "merging cooc file $COOC_PART_FILE_NAME[$i]...\n";
	open($PF[$i],$COOC_PART_FILE_NAME[$i]) or die "ERROR: Can't read $COOC_PART_FILE_NAME[$i]";
	my $pf = $PF[$i];
	$CURRENT[$i] = <$pf>;
	chop($CURRENT[$i]) if $CURRENT[$i];
    }

    while(1) {
	my ($min1,$min2) = (1e20,1e20);
        for(my $i=0;$i<scalar(@COOC_PART_FILE_NAME);$i++) {
	    next unless $CURRENT[$i];
	    my ($w1,$w2) = split(/ /,$CURRENT[$i]);
	    if ($w1 < $min1 || ($w1 == $min1 && $w2 < $min2)) {
		$min1 = $w1;
		$min2 = $w2;
	    }
	}
	last if $min1 == 1e20;
	print COOC "$min1 $min2\n";
        for(my $i=0;$i<scalar(@COOC_PART_FILE_NAME);$i++) {
	    next unless $CURRENT[$i];
	    my ($w1,$w2) = split(/ /,$CURRENT[$i]);
	    if ($w1 == $min1 && $w2 == $min2) {
		my $pf = $PF[$i];
		$CURRENT[$i] = <$pf>;
		chop($CURRENT[$i]) if $CURRENT[$i];
	    }
	}	
    }
    for(my $i=0;$i<scalar(@COOC_PART_FILE_NAME);$i++) {
	close($PF[$i]);
    }
    close(COOC);
}

sub run_single_giza {
    my($dir,$e,$f,$vcb_e,$vcb_f,$train) = @_;

    my %GizaDefaultOptions = 
	(p0 => .999 ,
	 m1 => 5 , 
	 m2 => 0 , 
	 m3 => 3 , 
	 m4 => 3 , 
	 o => "giza" ,
	 nodumps => 1 ,
	 onlyaldumps => 1 ,
	 nsmooth => 4 , 
         model1dumpfrequency => 1,
	 model4smoothfactor => 0.4 ,
	 t => $vcb_f,
         s => $vcb_e,
	 c => $train,
	 CoocurrenceFile => "$dir/$f-$e.cooc",
	 o => "$dir/$f-$e");
	
	if (defined $_DICTIONARY)
	{ $GizaDefaultOptions{d} = $___CORPUS_DIR."/gizadict.$f-$e"; }
	
	# 5 Giza threads
	if (defined $_MGIZA){ $GizaDefaultOptions{"ncpus"} = $_MGIZA_CPUS; }

    if ($_HMM_ALIGN) {
       $GizaDefaultOptions{m3} = 0;
       $GizaDefaultOptions{m4} = 0;
       $GizaDefaultOptions{hmmiterations} = 5;
       $GizaDefaultOptions{hmmdumpfrequency} = 5;
       $GizaDefaultOptions{nodumps} = 0;
    }

    if ($___FINAL_ALIGNMENT_MODEL) {
        $GizaDefaultOptions{nodumps} =               ($___FINAL_ALIGNMENT_MODEL =~ /^[345]$/)? 1: 0;
        $GizaDefaultOptions{model345dumpfrequency} = 0;
        
        $GizaDefaultOptions{model1dumpfrequency} =   ($___FINAL_ALIGNMENT_MODEL eq '1')? 5: 0;
        
        $GizaDefaultOptions{m2} =                    ($___FINAL_ALIGNMENT_MODEL eq '2')? 5: 0;
        $GizaDefaultOptions{model2dumpfrequency} =   ($___FINAL_ALIGNMENT_MODEL eq '2')? 5: 0;
        
        $GizaDefaultOptions{hmmiterations} =         ($___FINAL_ALIGNMENT_MODEL =~ /^(hmm|[345])$/)? 5: 0;
        $GizaDefaultOptions{hmmdumpfrequency} =      ($___FINAL_ALIGNMENT_MODEL eq 'hmm')? 5: 0;
        
        $GizaDefaultOptions{m3} =                    ($___FINAL_ALIGNMENT_MODEL =~ /^[345]$/)? 3: 0;
        $GizaDefaultOptions{m4} =                    ($___FINAL_ALIGNMENT_MODEL =~ /^[45]$/)? 3: 0;
        $GizaDefaultOptions{m5} =                    ($___FINAL_ALIGNMENT_MODEL eq '5')? 3: 0;
    }

    if (scalar(@_BASELINE_ALIGNMENT_MODEL)) {
        $GizaDefaultOptions{oldTrPrbs} = $_BASELINE_ALIGNMENT_MODEL[4 + ($dir eq $___GIZA_F2E?2:0)];
        $GizaDefaultOptions{oldAlPrbs} = $_BASELINE_ALIGNMENT_MODEL[5 + ($dir eq $___GIZA_F2E?2:0)];
        $GizaDefaultOptions{step_k} = 1;
    }

    if ($___GIZA_OPTION) {
	foreach (split(/[ ,]+/,$___GIZA_OPTION)) {
	    my ($option,$value) = split(/=/,$_,2);
	    $GizaDefaultOptions{$option} = $value;
	}
    }

    my $GizaOptions;
    foreach my $option (sort keys %GizaDefaultOptions){
	my $value = $GizaDefaultOptions{$option} ;
	$GizaOptions .= " -$option $value" ;
    }
    
    &run_single_snt2cooc($dir,$e,$f,$vcb_e,$vcb_f,$train) if $___PARTS == 1;

    print STDERR "(2.1b) running giza $f-$e @ ".`date`."$GIZA $GizaOptions\n";


    if (-e "$dir/$f-$e.$___GIZA_EXTENSION.gz") {
      print "  $dir/$f-$e.$___GIZA_EXTENSION.gz seems finished, reusing.\n";
      return;
    }
    print "$GIZA $GizaOptions\n";
    return if  $___ONLY_PRINT_GIZA;
    safesystem("$GIZA $GizaOptions");
 
	if (defined $_MGIZA and (!defined $___FINAL_ALIGNMENT_MODEL or $___FINAL_ALIGNMENT_MODEL ne '2')){
		print STDERR "Merging $___GIZA_EXTENSION.part\* tables\n";
		safesystem("$MGIZA_MERGE_ALIGN  $dir/$f-$e.$___GIZA_EXTENSION.part*>$dir/$f-$e.$___GIZA_EXTENSION");
		#system("rm -f $dir/$f-$e/*.part*");
	}


    die "ERROR: Giza did not produce the output file $dir/$f-$e.$___GIZA_EXTENSION. Is your corpus clean (reasonably-sized sentences)?"
      if ! -e "$dir/$f-$e.$___GIZA_EXTENSION";
    safesystem("rm -f $dir/$f-$e.$___GIZA_EXTENSION.gz") or die;
    safesystem("gzip $dir/$f-$e.$___GIZA_EXTENSION") or die;
}

sub run_single_snt2cooc {
  my($dir,$e,$f,$vcb_e,$vcb_f,$train) = @_;
  print STDERR "(2.1a) running snt2cooc $f-$e @ ".`date`."\n";
  my $suffix = (scalar @_BASELINE_ALIGNMENT_MODEL) ? ".new" : "";
  safesystem("mkdir -p $dir") or die("ERROR");
  if ($SNT2COOC eq "$_EXTERNAL_BINDIR/snt2cooc.out") {
    print "$SNT2COOC $vcb_e $vcb_f $train > $dir/$f-$e.cooc$suffix\n";
    safesystem("$SNT2COOC $vcb_e $vcb_f $train > $dir/$f-$e.cooc$suffix") or die("ERROR");
  } else {
    print "$SNT2COOC $dir/$f-$e.cooc$suffix $vcb_e $vcb_f $train\n";
    safesystem("$SNT2COOC $dir/$f-$e.cooc$suffix $vcb_e $vcb_f $train") or die("ERROR");
  }
  &merge_cooc_files($dir,$e,$f,"$dir/$f-$e.cooc.new",$_BASELINE_ALIGNMENT_MODEL[2 + ($dir eq $___GIZA_F2E?1:0)])
    if scalar @_BASELINE_ALIGNMENT_MODEL;
}


sub full_path {
    my ($PATH) = @_;
    return if $$PATH =~ /^\//;
    $$PATH = `pwd`."/".$$PATH;
    $$PATH =~ s/[\r\n]//g;
    $$PATH =~ s/\/\.\//\//g;
    $$PATH =~ s/\/+/\//g;
    my $sanity = 0;
    while($$PATH =~ /\/\.\.\// && $sanity++<10) {
	$$PATH =~ s/\/+/\//g;
	$$PATH =~ s/\/[^\/]+\/\.\.\//\//g;
    }
    $$PATH =~ s/\/[^\/]+\/\.\.$//;
    $$PATH =~ s/\/+$//;
}

sub safesystem {
  print STDERR "Executing: @_\n";
  system(@_);
  if ($? == -1) {
      print STDERR "ERROR: Failed to execute: @_\n  $!\n";
      exit(1);
  }
  elsif ($? & 127) {
      printf STDERR "ERROR: Execution of: @_\n  died with signal %d, %s coredump\n",
          ($? & 127),  ($? & 128) ? 'with' : 'without';
      exit(1);
  }
  else {
    my $exitcode = $? >> 8;
    print STDERR "Exit code: $exitcode\n" if $exitcode;
    return ! $exitcode;
  }
}

sub open_or_zcat {
  my $fn = shift;
  my $read = $fn;
  $fn = $fn.".gz" if ! -e $fn && -e $fn.".gz";
  $fn = $fn.".bz2" if ! -e $fn && -e $fn.".bz2";
  if ($fn =~ /\.bz2$/) {
      $read = "$BZCAT $fn|";
  } elsif ($fn =~ /\.gz$/) {
      $read = "$ZCAT $fn|";
  }
  my $hdl;
  open($hdl,$read) or die "Can't read $fn ($read)";
  return $hdl;
}


