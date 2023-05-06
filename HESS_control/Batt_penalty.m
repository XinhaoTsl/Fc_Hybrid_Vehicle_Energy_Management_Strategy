function [penalty] = Batt_penalty(sf)
    penalty = sf .* (exp(8.5*(sf - 1.5)));
end