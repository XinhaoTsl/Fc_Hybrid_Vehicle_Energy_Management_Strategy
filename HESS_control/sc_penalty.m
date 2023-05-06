function [penalty] = sc_penalty(solved_soc, ref_soc)
global sc_soc_acceptableRange
    if length(solved_soc) == 1
        if abs(solved_soc-ref_soc) - sc_soc_acceptableRange > 0
            penalty = exp(40 .* (abs(solved_soc-ref_soc) - sc_soc_acceptableRange));
        else
            penalty = exp(20 .* (abs(solved_soc-ref_soc) - sc_soc_acceptableRange));
        end

    else
        penalty = solved_soc;
        penalty(abs(solved_soc-ref_soc) - sc_soc_acceptableRange > 0) = ...
            exp(40 .* (abs(solved_soc(abs(solved_soc-ref_soc) - ...
            sc_soc_acceptableRange > 0)-ref_soc)) - sc_soc_acceptableRange);
        penalty(abs(solved_soc-ref_soc) - sc_soc_acceptableRange <= 0) = ...
            exp(20 .* (abs(solved_soc(abs(solved_soc-ref_soc) - ...
            sc_soc_acceptableRange <= 0)-ref_soc)) - sc_soc_acceptableRange);

    end

end