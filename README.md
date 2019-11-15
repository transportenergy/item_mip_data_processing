# item_mip_data_processing
R package for model intercomparison project (MIP) data processing

The iTEM Model Intercomparison Project (MIP) performs a number of steps to data submitted by the various modeling teams, for harmonization, regional re-scaling, and derivation of variables of interest. The `item_mip_data_processing` R package processes model submission datasets to produce the harmonized database that is used for generating figures and performing data analysis.

Running the scripts requires obtaining the model submission data, formatted with a specific structure. As these datasets are not public, they are not included with the package; instead, please contact one of the iTEM data team organizers to see about access. Running the package can be done as follows:

1) Open `item_mip_data_processing.Rproj`

2) Build and load the package

3) Perform the iTEM data processing by specifying (at a minimum) the folder where the model data are located, the names of the models whose output is to be processed (case sensitive), and the output folder where the database should be placed.
`perform_item_data_processing(path_to_model_data_folder, model_names, output_folder)`

There are a number of user-configurable features that can be modified to produce variations on the database; please see the documentation of the functions called.