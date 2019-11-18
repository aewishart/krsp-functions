# krsp functions
There are many common tasks that we do using the database.  McAdam has written some functions that can be called directly from GitHub to perform these tasks rather than relying on the circulation of summary tables for analysis or circulating code for creating these tables.  As an example, code has been uploaded that will generate annual measures of the cone index from the raw cone data rather than circulating a csv of summary cone data that others can import and then join to their tables for analysis.  Here someone can call this code and it will create the cone tables locally from the database in the cloud.

Note: Users must have access to the krsp cloud database in order to run this R code, since authentication is required.  If you do not have access and would like access to the database please contact Andrew McAdam at the University of Guelph.

These functions depend on the user having krsp_user and krsp_password already defined in their system settings.  See [here] (https://github.com/KluaneRedSquirrelProject/Using-the-KRSP-Cloud-Database/blob/master/Connecting%20to%20KRSP.md) for instructions on how to assign these credentials.
