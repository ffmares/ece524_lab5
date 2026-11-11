% Lab 5 Part I. Run in MATLAB with Signal Processing Toolbox, then re-run
% setup_lab5.tcl so the Verilog header and FIR Compiler use the SAME coefficients.
root = fileparts(fileparts(mfilename('fullpath')));
f = [0 0.5 0.5 1];
m = [1 1 0 0];
b = fir2(20, f, m);
c = round(b * 32767 / sum(b));
assert(numel(c) == 21 && all(c >= -32768 & c <= 32767));
assert(isequal(c, fliplr(c)));
out = fullfile(root, 'coefficients');
fid = fopen(fullfile(out, 'fir_coefficients.txt'), 'w');
fprintf(fid, '%d\n', c); fclose(fid);
fid = fopen(fullfile(out, 'fir_coefficients.coe'), 'w');
fprintf(fid, 'radix=10;\ncoefdata=\n');
fprintf(fid, '%d,\n', c(1:end-1)); fprintf(fid, '%d;\n', c(end)); fclose(fid);
fid = fopen(fullfile(root, 'ece524_lab5.srcs', 'sources_1', 'new', 'fir_defs.vh'), 'w');
fprintf(fid, ['// Include inside each module; deliberately no global include guard.\n' ...
 'localparam TAPS = 21;\nlocalparam DATA_WIDTH = 16;\nlocalparam ACC_WIDTH = 37;\n' ...
 'function signed [15:0] coeff;\n    input integer index;\n    begin\n        case (index)\n']);
for k = 1:21
    sign_text = '';
    if c(k) < 0, sign_text = '-'; end
    fprintf(fid, '            %d: coeff = %s16''sd%d;\n', k-1, sign_text, abs(c(k)));
end
fprintf(fid, '            default: coeff = 16''sd0;\n        endcase\n    end\nendfunction\n');
fclose(fid);
[h, w] = freqz(b, 1, 128);
[hq, wq] = freqz(c / 32767, 1, 128);
figure; plot(f, m, '--', w/pi, abs(h), wq/pi, abs(hq)); grid on;
xlabel('Normalized frequency (1 = 2.5 MHz)'); ylabel('Magnitude');
legend('Desired', 'fir2', '16-bit integer coefficients');
saveas(gcf, fullfile(out, 'frequency_response.png'));
save(fullfile(out, 'matlab_design.mat'), 'b', 'c', 'h', 'w', 'hq', 'wq');
fprintf('DC coefficient sum: %d; 500 kHz gain: %.6f; 1.6 MHz gain: %.6f\n', ...
 sum(c), abs(sum(c.*exp(-1j*2*pi*0.5/5*(0:20))))/32767, ...
 abs(sum(c.*exp(-1j*2*pi*1.6/5*(0:20))))/32767);
