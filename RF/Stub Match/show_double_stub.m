function show_double_stub(Z_L, Z_S, f0, freqs, Zline, Zstub)
% SHOW_DOUBLE_STUB Shows double stub match solutions
%
%	SHOW_DOUBLE_STUB(ZL, ZS, F0) Show double stub solutions matching from ZL
%	to ZS, at a center frequency of F0. 50 ohm lines are used.
%
%	SHOW_DOUBLE_STUB(ZL, ZS, F0, FREQS) Plot results over frequencies
%	specified in FREQS.
%
%	SHOW_DOUBLE_STUB(ZL, ZS, F0, FREQS, ZLINE, ZSTUB) Specify the
%	characeteristic impedances of the series line (ZLINE) and stub (ZSTUB).
%
% See also show_double_stub.

    if ~exist("Zline", "var")
        Zline = 50;
    end

    if ~exist("Zstub", "var")
        Zstub = 50;
    end

    if ~exist("freqs", "var")
        freqs = linspace(f0/2, f0.*1.5, 51);
    end
    
    j = sqrt(-1);
    
    Z_L = 10-j*20;
    Z_S = 30;
    Z_I = sqrt(Z_S*Z_L);
    
    % Find solutions
    solns_1 = Lmatch(Z_S, Z_I, Zline, Zstub, freqs, f0);
    solns_2 = Lmatch(Z_I, Z_L, Zline, Zstub, freqs, f0);
    
    mt = MTable;
    mt.row(["Stage", "Solution", "Bandwidth (MHz)"]);
    
    barprint("Stage 1");
    BW_1 = zeros(1, 4);
    count = 0;
    for s = solns_1
	    count = count + 1;
	    displ(s.str());
	    displ();
	    [BW_1(count), ~, ~] = s.bandwidth("Absolute");
	    mt.row(["1", s.name, num2str(BW_1(count)./1e6)]);
    end
    opt_idx1 = find(max(BW_1));
    
    barprint("Stage 2");
    BW_2 = zeros(1, 4);
    count = 0;
    for s = solns_2
	    count = count + 1;
	    displ(s.str());
	    displ();
	    [BW_2(count), ~, ~] = s.bandwidth("Absolute");
	    mt.row(["2", s.name, num2str(BW_2(count)./1e6)]);
    end
    
    mt.title("Stage Bandwidth Summary");
    displ(mt.str());
    
    figure(1);
    plotBandwidth(solns_1, freqs, 2, 2, -10);
    
    figure(2);
    plotBandwidth(solns_2,freqs, 2, 2, -10);
	
    ss = mergesolutions(solns_1, solns_2);
    
    barprint("Combined 2-Stage Network");
    BW_C = zeros(1, 16);
    count = 0;
    mt2 = MTable;
    mt2.row(["Stage", "Solution", "Bandwidth (MHz)"]);
    for s = ss
	    count = count + 1;
	    displ(s.str());
	    displ();
	    [BW_C(count), ~, ~] = s.bandwidth("Absolute");
    % 	mt2.row(["Combined", s.name, num2str(BW_C(count)./1e6)]);
	    mt2.row(["Combined", s.name, num2str(BW_C(count)./1e6)]);
    end
    opt_idx_C = find(max(BW_C));
    
    mt2.title("Combined Network Bandwidth");
    
    displ(mt2.str());
    
    figure(3);
    plotBandwidth(ss, freqs, 4, 4, -10);
    
    % Single Stub Control
    solns_ctrl = Lmatch(Z_S, Z_L, Zline, Zstub, freqs, f0);
    
    figure(4);
    plotBandwidth(solns_ctrl, freqs, 2, 2);
    
    barprint("Control 1-Stage Network");
    BW_ctrl = zeros(1, 4);
    count = 0;
    mt3 = MTable;
    mt3.row(["Solution", "Bandwidth (MHz)"]);
    for s = solns_ctrl
	    count = count + 1;
	    displ(s.str());
	    displ();
	    [BW_ctrl(count), ~, ~] = s.bandwidth("Absolute");
    % 	mt2.row(["Combined", s.name, num2str(BW_C(count)./1e6)]);
	    mt3.row([s.name, num2str(BW_ctrl(count)./1e6)]);
    end
    mt3.title("Control Bandwidth");
    opt_idx_ctrl = find(max(BW_ctrl));
    
    displ(mt3.str());
    
    % This isn't so helpful - there are lots of soltuions that don't play so
    % nicely together.
    figure(5);
    hold off
    scatter(1:4, BW_ctrl./1e6, 'Marker', '*');
    hold on
    scatter(1:16, BW_C./1e6, 'Marker', '*');
    xlabel("Solution Number");
    ylabel("BW (MHz)");
    title("Bandwidth of Single vs Double Stub Solutions");
    legend("Single Stub Solutions", "Double Stub Solutions");
    grid on
    hlin(mean(BW_ctrl./1e6), 'LineStyle', '--', 'Color', [0    0.4470    0.7410]);
    hlin(mean(BW_C./1e6), 'LineStyle', '--', 'Color', [0.8500    0.3250    0.0980]);
    
    figure(6);
    hold off;
    plot(freqs./1e9, lin2dB(abs(solns_ctrl(opt_idx_ctrl).G_in())));
    hold on;
    plot(freqs./1e9, lin2dB(abs(ss(opt_idx_C).G_in())));
    xlabel("Frequency (GHz)");
    ylabel("\Gamma_{In} (dB)");
    title("Comparison of Optimal Single and Double Stub Matches");
    legend("Single Stub Match", "Double Stub Match");
    
    % Calculate bandwidth
    [bw_ctrl, f0_ctrl, f1_ctrl]=solns_ctrl(opt_idx_ctrl).bandwidth( "Absolute");
    [bw_C, f0_C, f1_C]=ss(opt_idx_C).bandwidth( "Absolute");
    
    % Plot Bandwidth Region
    if ~isempty(bw_ctrl)
	    vlin(f0_ctrl./1e9, 'LineStyle', '--', 'Color', [0, 0, .8]);
	    vlin(f1_ctrl./1e9, 'LineStyle', '--', 'Color', [0, 0, .8]);
    end
    
    if ~isempty(bw_C)
	    vlin(f0_C./1e9, 'LineStyle', '--', 'Color', [.8, 0, 0]);
	    vlin(f1_C./1e9, 'LineStyle', '--', 'Color', [.8, 0, 0]);
    end
    
    % Add finishing touches to graph
    grid on;
    ylim([-50, 0]);


















end