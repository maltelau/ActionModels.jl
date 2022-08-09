"""""
function fit_model(
    agent::AgentStruct,
    inputs::Vector{Float64},
    responses::Union{Vector{Float64},Missing},
    params_priors_list = (;)::NamedTuple{Distribution},
    fixed_params_list = (;)::NamedTuple{String,Real},
    sampler = NUTS(),
    iterations = 1000,
)
Function to fit an agent parameters.
"""
function fit_model(
    agent::AgentStruct,
    inputs::Vector,
    responses::Vector,
    params_priors_list::NamedTuple,
    fixed_params_list = (;),
    sampler = NUTS(),
    n_iterations = 1000,
    n_chains = 1,
)

    #RUN IT FORWARDS FIRST, PUT IN TRY IN THE FITTING STEP

    #Store old parameters 
    old_params = get_params(agent)

    #Set fixed parameters if specified
    set_params!(agent, fixed_params_list)

    #Initialize dictionary for storing sampled parameters
    fitted_params = Dict()

    #Create turing model macro for parameter estimation
    @model function fit_agent(responses)

        #Give Turing prior distributions for each fitted parameter
        for param_key in keys(params_priors_list)
            fitted_params[string(param_key)] ~ getfield(params_priors_list, param_key)
        end 

        ## Create agent with sampled parameters ##
        #Initialize lists for storing parameter name symbols and sampled parameter values
        param_name_symbols = []
        param_sampled_values = []

        #Populate lists with names and sampled values from the priors
        for (param_name, sampled_param) in fitted_params
            push!(param_name_symbols, Symbol(param_name))
            push!(param_sampled_values, sampled_param)
        end

        #Merge into one named tuple
        sampled_params = NamedTuple{Tuple(param_name_symbols)}(param_sampled_values)

        #Set agent parameters to the sampled values
        set_params!(agent, sampled_params)
        reset!(agent)

        ## Fit model ##
        #For each input
        for input_indx in range(1, length(inputs))
            #Input it into the agent's action model to give Turing the probability distribution for the observed action
            responses[input_indx] ~ agent.action_model(agent, inputs[input_indx])
        end
    end

    #Fit model to inputs and responses, as many separate chains as specified
    chains = map(i -> sample(fit_agent(responses), sampler, n_iterations), 1:n_chains)
    #Concatenate chains together
    chains = chainscat(chains...)

    ## Set readable chain names ###
    #Initialize dict for replacement names to give to Turing
    params_name = Dict()
    #For each parameter
    for param in keys(params_priors_list)
        #Set to replace the fitted_params[] version with just the parameter name
        params_name["fitted_params["*string(param)*"]"] = String(param)
    end
    #Input the dictionary to replace the names
    chains = replacenames(chains, params_name)

    #Reset the agent to its original parameters
    set_params!(agent, old_params)
    reset!(agent)

    return chains
end