use strict;
use warnings;
use ElectricCommander;

my $ec = new ElectricCommander;

sub getPropertyValue($);

# Get the parameter values
my $application = getPropertyValue("/myParent/application");
my $environment = getPropertyValue("/myParent/environment");
my $process = getPropertyValue("/myParent/process");
my $project = getPropertyValue("/myParent/project");
my $timeout = getPropertyValue("/myParent/timeout");
my $parameters_raw = getPropertyValue("/myParent/parameters");
my $parameters = eval('[' . $parameters_raw . ']');

# Launch the process
$ec->setProperty("/myJob/ec_job_progress_status", "Launching process...");
my $result = $ec->runProcess($project, $application, $process, "$application-$environment", {
    actualParameter => $parameters
});

# Link between the wrapper job and the process job
my $job_id = $result->findvalue("//jobId")->value();
$ec->setProperty("/myParent/process_job_id", $job_id);
my $link = "/commander/link/jobDetails/jobs/$job_id";
$ec->setProperty("/myJob/report-urls/Application Process Job", $link);
$ec->setProperty("/jobs/$job_id/report-urls/Wrapper",
    "/commander/link/jobDetails/jobs/$[jobId]");
$ec->setProperty("/myJob/ec_job_description",
    "<html><div style='padding:5px'><a target='_blank' href='$link'>View Job</a></div></html>");

# If we're in a workflow state, link between the workflow and the process job
my $workflow_name = $ec->expandString('$' . "[/javascript myWorkflow.workflowName;]")
    ->findvalue("//value")->value();
if ($workflow_name ne "") {
    my $workflow_project = $ec->expandString(
        '$' . "[/javascript myWorkflow.projectName;]")->findvalue("//value")->value();
    my $workflow_state = $ec->expandString(
        '$' . "[/javascript myState.stateName;]")->findvalue("//value")->value();
    $ec->setProperty("/projects/$workflow_project/workflows/$workflow_name"
        . "/report-urls/$workflow_state $process", $link);
    $ec->setProperty("/jobs/$job_id/report-urls/Workflow",
        "/commander/link/workflowDetails/projects/$workflow_project"
        . "/workflows/$workflow_name");
}

# Wait for the job to complete
$ec->setProperty("/myJob/ec_job_progress_status", "Process running...");
$ec->waitForJob($job_id, {timeout => $timeout});

# Mirror the process job's outcome to the wrapper job
my $outcome = $ec->getJobInfo($job_id)->findvalue("//outcome")->value();
if ($outcome eq "error") {
    $ec->setProperty("summary", "Application process failed!");
    $ec->setProperty("/myJob/ec_job_progress_status", "Process failed");
    exit 1;
}
$ec->setProperty("summary", "Application process succeeded!");
$ec->setProperty("/myJob/ec_job_progress_status", "Process succeeded");

# Helper method to extract the value of a property
sub getPropertyValue($) {
    my ($name) = @_;
    return $ec->getProperty($name)->findvalue("//value")->value();
}
