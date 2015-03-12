OVERVIEW:

The "ProcessWrapper" ElectricCommander/ElectricFlow plugin provides a procedure that launches an application process and waits for it to complete.  This enables continuous integration triggers, workflow states, and so on to call application processes.

USAGE:

You must first install and promote the plugin (available in out/ProcessWrapper.jar).  When you are creating a continuous integration trigger or workflow state to launch an application process, select the ProcessWrapper plugin as the project and ProcessWrapper as the procedure.  You are prompted for the following parameters:
- application: Name of the application whose process is being launched.
- environment: Name of the environment in which to launch the application process.
- parameters: Parameters to the application process in the format passed to an ec-perl runProcess call. Required parameters to the starting state must be specified or the process won't be launched. Example:
```
    {actualParameterName => "ec_MyComponent-version", value => "3.4.1"},
    {actualParameterName => "ec_smartDeployOption", value => 0},
```
- process: Name of the application process to launch.
- project: Name of the project in which the application has been created.
- timeout: Number of seconds to wait for the job to complete before timing out.

Once the CI trigger or workflow state fires, it creates a job that does the following:
- Launches the application process by calling the runProcess API.
- Creates links from the wrapper job to the application process job.
- Creates links from the workflow to the application process job (if being run from a workflow).
- Waits for the application process job to complete.
- Once it completes, mirror the outcome of the application process job to the wrapper job, so failures are easily identified.

SOURCES:

The sources are available in the src directory. They were built using the Commander SDK v2.0. The documentation for the SDK is available at http://docs.electric-cloud.com.

AUTHOR:

Tanay Nagjee, Electric Cloud Solutions Architect
tanay@electric-cloud.com

DISCLAIMER:

This module is not officially supported by Electric Cloud.