function [soc_next] = Sc_state_transf(ScSoc, P_sc)

global sc_E

soc_next = ScSoc - 1000*P_sc/sc_E;

end