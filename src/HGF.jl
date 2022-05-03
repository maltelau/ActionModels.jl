module HGF

#Load packages
using Distributions, RecipesBase, Turing
#using DataFrames


### The HGF forward model ###
#Structures and types
include("hgf_perception_model/structs.jl")

#Functions for initializing the HGF structure
include("hgf_perception_model/init_hgf.jl")

#Functions implementing update equations
include("hgf_perception_model/update_equations.jl")

#Functions for updating single nodes
include("hgf_perception_model/update_node.jl")

#Functions for updating a full HGF
include("hgf_perception_model/update_hgf.jl")

#Get premade models
include("hgf_perception_model/premade_models.jl")


### Action models ###
#Structures and types
include("action_model/structs.jl")

#Premade action models
include("action_model/premade_models.jl")

#Setting up action models
include("action_model/init_agent.jl")


### Model Fitting ###
#Fitting function
include("model_fitting/fit_model.jl")
#Simultaing function
include("model_fitting/get_responses.jl")


### Plotting ###
#Trajectory plots
include("plots/trajectory_plot.jl")


### Utility Code ###
#Function for inputting data
include("utils/give_inputs.jl")
#Reset function
include("utils/reset.jl")
#Function to change HGF parameters
include("utils/change_params.jl")
#Function to get HGF parameters
include("utils/get_params.jl")

#End of module
end