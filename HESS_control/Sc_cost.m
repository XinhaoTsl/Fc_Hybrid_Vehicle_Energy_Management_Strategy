function value = Sc_cost(ScSoc, ssoc_ref, P_sc)

    global sc_E
    
    soc_next = ScSoc - 1000.*P_sc./sc_E;
    value = sc_penalty(soc_next, ssoc_ref);

end
