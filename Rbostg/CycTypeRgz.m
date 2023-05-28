%% xinhaoxu@tesla.com
%  Drive cycle rule-based recognition (This script based on the Fun_SLMP.m)

len = length(vstd_formal);
updateLen = 50;
ssc = 0;    % SubStepCount
sssc = 0;   % SubStepStopCount
dct = zeros(1,len);
ssVacc = zeros(1,updateLen);
ssVspd = zeros(1,updateLen);

for step = 1:len
    ssc = ssc + 1;

    if step < updateLen
        if max(vave_formal(step)) <= 10
            dct(step) = 1; 
        elseif max(vave_formal(step)) <= 25 & max(vave_formal(step)) > 10
            dct(step) = 2;
        else
            dct(step) = 3;
        end
        ssVacc(ssc) = a_ave_formal(step);
        ssVspd(ssc) = vave_formal(step); 
    else

        if ssc < updateLen
            ssVacc(ssc) = a_ave_formal(step);
            ssVspd(ssc) = vave_formal(step);    % SubStep Vehicle Speed
            if floor(ssVspd(ssc)) == 0          % Vehicle Stop Count
                sssc = sssc + 1; end
            dct(step) = dct(step-1);
    
        elseif ssc == updateLen
            svas = mean(ssVspd);     % Sublevel Vehicle Average Speed (svas)
            
            if step < 2*updateLen
                dct(step) = dct(step-1);

            elseif svas <= 10
                if sum(ssVacc>=5)
                    if max(ssVspd) > 1.2*10 & floor(min(ssVspd)) == 0
                        dct(step) = 2;
                    elseif sum(ssVspd>10) > updateLen/2
                        dct(step) = 2; 
                    elseif max(ssVspd) < 1.2*10
                        dct(step) = 1;
                    end
                    dct(step) = 1; 
                end
                dct(step) = 1;
    
            elseif svas > 10 && svas <= 25
                if sum(ssVspd>25) > updateLen/2
                    if ssVspd(1) >= 25 && ssVspd(end) >= 25
                        dct(step) = 3;
                    elseif ssVspd(1) >= 25 && svas > 0.8*25
                        dct(step) = 3;
                    elseif max(ssVspd) > 25*1.2
                        dct(step) = 3;
                    else
                        dct(step) = 2;
                    end
                    dct(step) = 2;
                elseif ssVspd(1) >= 25 && ssVspd(end) >= 25
                    dct(step) = 3;
                elseif ssVspd(1) >= 25 && svas > 0.8*25
                    dct(step) = 3;
                else
                    dct(step) = 2;
                end
            else
                dct(step) = 3;
            end

            ssc = 1;
            ssVacc = zeros(1,updateLen);
            ssVspd = zeros(1,updateLen);

            ssVacc(ssc) = a_ave_formal(step);
            ssVspd(ssc) = vave_formal(step);
        end
    end
end

Fixedct = [dct(updateLen:end),dct(end)*ones(1,updateLen-1)];