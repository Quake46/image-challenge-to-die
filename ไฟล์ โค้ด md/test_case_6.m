%% =========================================================================
% Image Processing Challenge 05: Scene Text Detection & Recognition
% Test Case 6: ภาพ Image14.jpg (ป้ายร้าน Arturo's Coal Oven Pizza)
% - แยก Bounding Box เป็น 2 รูป: (1) แสดงข้อความ (2) แสดงค่า Confidence
% - รูปแบบ Figure และ Command Window Output เหมือนกับ Test Case 1-5 และ 7
% =========================================================================
clear all; close all; clc;

%% 0. พารามิเตอร์
DEBUG   = false;     % false = แสดงเฉพาะ Figure 1 และ Figure 2 เหมือนกับ testcase อื่น
VERBOSE = false;     % false = ไม่พิมพ์ผล OCR ตอน sweep เพื่อให้ Command Window สะอาด

roi_art  = [0,  85, 500, 160];     % [x y w h]  ข้อความ Arturo's
roi_coal = [0, 250, 150, 130];     % COAL / OVEN  (ไม่รวมจุดเหลือง 2 จุดทางขวา)

k_list = [0.7 0.8 0.9 1.0 1.1 1.2];            % ตัวคูณ threshold ที่ใช้ sweep
k_list_art = [1.1 1.2 1.3 1.5 1.8];             % Arturo's: ช่วงที่เริ่มเห็นตัวอักษรแยกกัน
sc_art  = [0.3 0.4 0.5 0.7];                    % ย่อภาพก่อน OCR (ตัวอักษรสูง ~100 px ใหญ่เกินไปสำหรับ Tesseract)
sc_coal = 1.5;
charset_art  = ['ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz' ''''];
charset_coal = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

%% 1. อ่านภาพ
f = imread('Image14.jpg');

%% 2. Segmentation + OCR แต่ละบริเวณ
[w1, c1, b1, info1] = ocr_region(f, roi_art,  charset_art,  k_list_art, true,  sc_art,  'ARTURO', [0 10 20], VERBOSE);
[w2, c2, b2, info2] = ocr_region(f, roi_coal, charset_coal, k_list, false, sc_coal, 'COALOVEN', 0, VERBOSE);

words = [w1(:); w2(:)];
confidences = [c1(:); c2(:)];
bboxes = [b1; b2];

%% 3. แสดงรูปภาพขั้นตอน Preprocessing ทุกขั้นตอน (Figure 1 สำหรับใส่สไลด์)
figure('Name', 'Preprocessing Pipeline (Test Case 6: Image14.jpg)', 'NumberTitle', 'off');
subplot(2, 3, 1); imshow(f);              title('(1) Original Scene (Image14.jpg)');
subplot(2, 3, 2); imshow(info1.feat, []); title('(2) Arturo''s Yellowness Feature');
subplot(2, 3, 3); imshow(info1.bw);       title('(3) Arturo''s Binarized Mask');
subplot(2, 3, 4); imshow(info2.feat, []); title('(4) COAL OVEN Yellowness Feature');
subplot(2, 3, 5); imshow(info2.bw);       title('(5) COAL OVEN Binarized Mask');
subplot(2, 3, 6); imshow(info2.proc);     title('(6) Final Inverted OCR Input');

if DEBUG
    figure('Name', 'DEBUG ROI', 'NumberTitle', 'off');
    imshow(f); hold on;
    rectangle('Position', roi_art,  'EdgeColor', 'c', 'LineWidth', 2);
    rectangle('Position', roi_coal, 'EdgeColor', 'm', 'LineWidth', 2);
    title('DEBUG: ROI (ฟ้า = Arturo''s, ม่วง = COAL OVEN)'); hold off;

    if ~isempty(info1.bw)
        [alpha, e1, H1, th1, rho1, pk1, ln1] = estimate_skew(info1.bw, 15);
        figure('Name', 'Canny + Hough (Arturo''s)', 'NumberTitle', 'off');
        subplot(1,3,1); imshow(e1); title('Canny edge');
        subplot(1,3,2); imshow(H1, [], 'XData', th1, 'YData', rho1, 'InitialMagnification', 'fit');
        axis on; axis normal; hold on; xlabel('\theta'); ylabel('\rho');
        if ~isempty(pk1), plot(th1(pk1(:,2)), rho1(pk1(:,1)), 's', 'Color', 'w'); end
        title(sprintf('Hough (skew = %.2f deg)', alpha));
        subplot(1,3,3); imshow(e1); hold on; title('houghlines');
        for k = 1:numel(ln1)
            xy = [ln1(k).point1; ln1(k).point2];
            plot(xy(:,1), xy(:,2), 'LineWidth', 3, 'Color', [.6 .6 .6]);
        end
    end
end

%% 4. แสดงผล Bounding Box แยกเป็น 2 รูป (Figure 2 สำหรับใส่สไลด์)
figure('Name', 'OCR Detection Results (Test Case 6: Image14.jpg)', 'NumberTitle', 'off');

% --- รูปที่ 1: แสดง Bounding Box พร้อม "ข้อความที่อ่านได้ (Recognized Words)" ---
subplot(1, 2, 1);
imshow(f); hold on;
title('1. Bounding Box: ข้อความที่อ่านได้ (Recognized Words)');
for i = 1:length(words)
    box = bboxes(i, :);
    w = words{i};
    rectangle('Position', box, 'EdgeColor', 'g', 'LineWidth', 2);
    text(box(1), max(box(2)-10, 10), w, ...
        'Color', 'y', 'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', 'k', 'Margin', 2, 'Interpreter', 'none');
end
hold off;

% --- รูปที่ 2: แสดง Bounding Box พร้อม "ค่าความเชื่อมั่น (Confidence)" ---
subplot(1, 2, 2);
imshow(f); hold on;
title('2. Bounding Box: ค่าความเชื่อมั่น (Word Confidence)');
for i = 1:length(words)
    box = bboxes(i, :);
    conf = confidences(i);
    rectangle('Position', box, 'EdgeColor', 'g', 'LineWidth', 2);
    text(box(1), max(box(2)-10, 10), sprintf('%.4f', conf), ...
        'Color', 'c', 'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', 'k', 'Margin', 2, 'Interpreter', 'none');
end
hold off;

%% 5. แสดงตารางสรุปผลการทดลองใน Command Window
groundTruth = {'ARTURO''S', 'COAL', 'OVEN'};

fprintf('\n=========================================================================\n');
fprintf('                 ตารางสรุปผลการทดลองของภาพ Test Case 6 (Image14.jpg)\n');
fprintf('=========================================================================\n');
fprintf('%-5s | %-15s | %-12s | %-18s | %-15s\n', ...
    'ลำดับ', 'คำที่ถูกต้อง (GT)', 'Confidence', 'คำที่อ่านได้', 'Recognition Rate');
fprintf('-------------------------------------------------------------------------\n');

totalConf = 0; totalRate = 0; validCount = length(words);
for i = 1:validCount
    recWord = upper(words{i});
    conf = confidences(i);
    
    bestRate = 0; matchedGT = '-';
    for g = 1:length(groundTruth)
        gt = upper(groundTruth{g});
        
        % เปรียบเทียบทั้งแบบตัดเครื่องหมายและแบบ Levenshtein
        cleanRec = regexprep(recWord, '[^a-zA-Z]', '');
        cleanGT  = regexprep(gt, '[^a-zA-Z]', '');
        
        if strcmpi(cleanRec, cleanGT)
            rate = 100.00;
        else
            rate = max(0, (1 - lev(recWord, gt) / max(length(gt), length(recWord))) * 100);
        end
        
        if rate > bestRate
            bestRate = rate; 
            matchedGT = groundTruth{g}; 
        end
    end
    
    totalConf = totalConf + conf;
    totalRate = totalRate + bestRate;
    
    fprintf('%-5d | %-15s | %-12.4f | %-18s | %-14.2f %%\n', ...
        i, matchedGT, conf, words{i}, bestRate);
end
fprintf('-------------------------------------------------------------------------\n');
if validCount > 0
    fprintf('ค่าเฉลี่ย:            | Confidence: %-6.4f |                     | Rate: %-6.2f %%\n', ...
        totalConf/validCount, totalRate/validCount);
else
    fprintf('ไม่พบข้อความที่อ่านได้\n');
end
fprintf('=========================================================================\n');

%% ========================= Local functions ===============================
function f8 = yellow_feature(img)
% ความเหลือง = min(R,G) - B  (ตัวอักษรเหลืองสูง, พื้นหลังแดง/เขียว/ขาวต่ำ)
    R = double(img(:,:,1)); G = double(img(:,:,2)); B = double(img(:,:,3));
    y = imgaussfilt(min(R, G) - B, 0.8);
    f8 = uint8(min(max(y, 0), 255));
end

function T = iter_thresh(f)
% Global thresholding แบบ iterative (ตามสไลด์ Gonzalez & Woods)
    f = double(f);
    T = 0.5 * (min(f(:)) + max(f(:)));
    for it = 1:100
        g = f >= T;
        if ~any(g(:)) || all(g(:)), break; end
        Tn = 0.5 * (mean(f(g)) + mean(f(~g)));
        if abs(T - Tn) < 0.5, T = Tn; break; end
        T = Tn;
    end
end

function bw2 = filter_regions(bw, minH, maxH, minArea)
% Region-based segmentation: predicate P(Ri) = TRUE ถ้าความสูงและพื้นที่สมเหตุสมผล
    cc = bwconncomp(bw);
    st = regionprops(cc, 'BoundingBox', 'Area');
    keep = find(arrayfun(@(s) s.Area >= minArea && ...
                              s.BoundingBox(4) >= minH && s.BoundingBox(4) <= maxH, st));
    bw2 = ismember(labelmatrix(cc), keep);
end

function [alpha, e, H, theta, rho, peaks, lines] = estimate_skew(bw, maxAng)
% Canny -> Hough -> มุมเอียงมัธยฐานของเส้นที่เกือบแนวนอน (|มุม| < maxAng)
    e = edge(bw, 'canny');
    [H, theta, rho] = hough(e, 'RhoResolution', 0.5);
    peaks = houghpeaks(H, 10);
    lines = houghlines(e, theta, rho, peaks, 'FillGap', 10, 'MinLength', 30);
    a = [];
    for k = 1:numel(lines)
        t = lines(k).theta;
        if t > 0, ak = t - 90; else, ak = t + 90; end
        if abs(ak) < maxAng, a(end+1) = ak; end %#ok<AGROW>
    end
    if isempty(a), alpha = 0; else, alpha = median(a); end
end

function [words, confs, boxes, info] = ocr_region(f, roi, charset, k_list, do_deskew, sc_list, tag, slant_list, verbose)
% segmentation (yellow feature + iterative threshold x k) -> predicate -> (deskew) -> OCR
% เลือก k ที่ให้ผลรวม (confidence x จำนวนตัวอักษร) สูงสุด
    if nargin < 9, verbose = false; end
    img  = imcrop(f, roi);
    feat = yellow_feature(img);
    T0   = iter_thresh(feat);
    Hh   = size(img, 1);

    words = {}; confs = []; boxes = zeros(0, 4);
    info = struct('bw', [], 'proc', [], 'alpha', 0, 'k', NaN, 'T0', T0, 'feat', feat);
    bestScore = -inf;

    [KK, SS, CC] = ndgrid(k_list, slant_list, sc_list);   % ลองทุกชุด (k, มุมตัวเอียง, สเกล)
    for idx = 1:numel(KK)
        k = KK(idx); sl = SS(idx); sc = CC(idx);
        bw = feat >= k * T0;
        bw = bwareaopen(bw, 30);
        bw = imclose(bw, strel('disk', 1));
        bw = filter_regions(bw, 0.06 * Hh, 0.98 * Hh, 30);
        if ~any(bw(:)), continue; end
        bw0 = bw;

        alpha = 0;
        if do_deskew
            alpha = estimate_skew(bw, 15);
            if abs(alpha) > 0.3, bw = imrotate(bw, alpha, 'nearest', 'crop'); end
        end

        if sl ~= 0     % แก้ตัวเอียงขวา (italic/หวัด): ดึงส่วนบนของตัวอักษรไปทางซ้าย
            bw = imwarp(uint8(bw), affine2d([1 0 0; tand(sl) 1 0; 0 0 1]), 'nearest') > 0;
        end

        [rr, cc] = find(bw);
        r0 = min(rr); r1 = max(rr); c0 = min(cc); c1 = max(cc);
        proc = padarray(imresize(~bw(r0:r1, c0:c1), sc), [25 25], 1, 'both');
        res  = ocr(proc, 'LayoutAnalysis', 'block', 'CharacterSet', charset);
        if verbose
            fprintf('   raw OCR: [%s]  wordConf=%s\n', strtrim(regexprep(res.Text, '\s+', ' ')), ...
                    mat2str(round(res.WordConfidences', 2)));
        end

        w_k = {}; c_k = []; b_k = zeros(0, 4);
        for i = 1:numel(res.Words)
            w = regexprep(strtrim(res.Words{i}), '[^a-zA-Z'']', '');
            c = res.WordConfidences(i);
            if length(w) >= 4 && c > 0.30
                b  = res.WordBoundingBoxes(i, :);
                bx = [(b(1)-25)/sc + c0 - 1 + roi(1), (b(2)-25)/sc + r0 - 1 + roi(2), b(3)/sc, b(4)/sc];
                w_k{end+1, 1} = w;       %#ok<AGROW>
                c_k(end+1, 1) = c;       %#ok<AGROW>
                b_k(end+1, :) = bx;      %#ok<AGROW>
            end
        end

        if do_deskew && ~isempty(w_k)          % ข้อความคำเดียว: รวมเป็นคำเดียว
            w_k = {strjoin(w_k', '')};
            c_k = mean(c_k);
            [rb, cb] = find(bw0);                % กรอบจาก mask ก่อนหมุน/เอียง = ตรงกับภาพจริง
            b_k = [min(cb) + roi(1) - 1, min(rb) + roi(2) - 1, ...
                   max(cb) - min(cb) + 1, max(rb) - min(rb) + 1];
        end

        if isempty(w_k), score = 0; else, score = sum(c_k .* cellfun(@length, w_k)); end
        if verbose
            fprintf('[%s] k=%.1f slant=%2d sc=%.1f alpha=%5.2f  words=%-20s score=%.2f\n', tag, k, sl, sc, alpha, strjoin(w_k', '|'), score);
        end

        if score > bestScore
            bestScore = score;
            words = w_k; confs = c_k; boxes = b_k;
            info.bw = bw0; info.proc = proc; info.alpha = alpha; info.k = k;
        end
    end
end

function d = lev(a, b)
% Levenshtein edit distance (ไม่สนตัวพิมพ์เล็ก/ใหญ่)
    a = upper(a); b = upper(b);
    m = length(a); n = length(b);
    D = zeros(m+1, n+1); D(:,1) = 0:m; D(1,:) = 0:n;
    for i = 1:m
        for j = 1:n
            D(i+1,j+1) = min([D(i,j+1)+1, D(i+1,j)+1, D(i,j) + (a(i) ~= b(j))]);
        end
    end
    d = D(m+1, n+1);
end
