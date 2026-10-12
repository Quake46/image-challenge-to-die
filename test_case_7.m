%% =========================================================================
% Scene Text Detection & Recognition : Image15.jpg
% สร้างจากเทคนิคในสไลด์ Image Segmentation Part I & II
%
%  Part I  : Canny edge detection (edge)
%  Part II : Hough transform (hough / houghpeaks / houghlines)
%            Global thresholding (iterative, Gonzalez & Woods)
%            Local thresholding (morphological opening -> background)
%            Region-based segmentation (predicate P(Ri) กรองบริเวณ)
%            Watershed + distance transform (bwdist / watershed)
%
%  เทคนิคที่ "ไม่ได้มาจากสไลด์": Polar-to-Cartesian unwrapping (คลี่ข้อความโค้ง)
%  และ Tesseract OCR (ocr) เพราะสไลด์ครอบคลุมเฉพาะการ segmentation
% =========================================================================
clear all; close all; clc;

%% 0. พารามิเตอร์ (พิกัดทั้งหมดอยู่ใน f_sign = ภาพที่ crop แล้ว)
DEBUG       = false;     % false = แสดงเฉพาะ Figure 1 และ Figure 2 เหมือนกับ testcase อื่น
USE_LEXICON = false;     % true = ใช้คำที่คาดไว้ช่วยเลือกผลและแก้คำที่ผิด <= 2 ตัว
                         % (ต้องระบุในรายงานว่าใช้ lexicon post-processing)

roi_sign   = [25, 80, 410, 500];
roi_open   = [15, 10, 385, 165];
roi_circle = [70, 170, 160, 160];          % ครอบวงกลมแดง (BEST)

cx = 143;  cy = 245;                        % ศูนย์กลางป้ายวงกลม
r_in = 88; r_out = 135;                     % วงแหวนตัวอักษร
th_worlds = [172, 10];                      % WORLD'S: ซ้าย -> ขวา (ตามเข็มนาฬิกา)
th_donuts = [196, 350];                     % DONUTS : ซ้ายล่าง -> ขวาล่าง
H_strip = 100; W_strip = 700;

k_list  = [0.8 0.9 1.0 1.1 1.2];            % ตัวคูณ threshold ที่ใช้ sweep
se_ring = 16;                               % รัศมี SE ของ top-hat บน strip (ต้องใหญ่กว่าครึ่งหนึ่งของความหนาเส้น)
VERBOSE = false;                            % false = ไม่พิมพ์ผล OCR ตอน sweep เพื่อให้ Command Window สะอาด
charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ''';

%% 1. อ่านภาพและ crop ป้าย
f = imread('Image15.jpg');
f_sign = imcrop(f, roi_sign);

%% 2. OPEN : Local thresholding + Canny/Hough deskew
f_open      = imcrop(f_sign, roi_open);
chroma_open = red_chroma(f_open);                  % ฟีเจอร์ที่ทนเงา
c8_open     = uint8(255 * mat2gray(chroma_open));

% Local thresholding (สไลด์: ใช้ imopen ประมาณพื้นหลัง) -> top-hat = f - opening(f)
se_open  = strel('disk', 15);                      % ใหญ่กว่าความหนาเส้นตัวอักษร
bg_open  = imopen(c8_open, se_open);
top_open = imtophat(c8_open, se_open);

% Global thresholding แบบ iterative (สไลด์ Gonzalez & Woods) บนภาพ top-hat
T_open  = iter_thresh(top_open);
bw_open = top_open >= T_open;
bw_open = bwareaopen(bw_open, 50);
bw_open = imclose(bw_open, strel('disk', 2));

% Part I+II: Canny edge -> Hough -> หามุมเอียงของเส้นแนวนอน แล้วปรับให้ตรง
[alpha, e_open, H_h, theta_h, rho_h, peaks_h, lines_h] = estimate_skew(bw_open);
if abs(alpha) > 0.3
    bw_open = imrotate(bw_open, alpha, 'nearest', 'crop');
end
final_open = padarray(~bw_open, [25 25], 1, 'both');

%% 3. BEST : Global thresholding (iterative) หาวงกลมแดง -> ตัวอักษร = ส่วนที่ไม่แดงในวง
f_circ   = imcrop(f_sign, roi_circle);
chroma_c = red_chroma(f_circ);

Tc = iter_thresh(uint8(255 * chroma_c)) / 255;
if Tc < 0.40 || Tc > 0.60, Tc = 0.47; end          % กันกรณี histogram ไม่เป็น bimodal
red_mask = bwareafilt((chroma_c > Tc) & (double(f_circ(:,:,1)) > 80), 1);

hull = bwconvhull(red_mask);
st   = regionprops(hull, 'Centroid', 'Area');
r_c  = sqrt(st(1).Area / pi);
[XX, YY] = meshgrid(1:size(hull,2), 1:size(hull,1));
disk_in  = (XX - st(1).Centroid(1)).^2 + (YY - st(1).Centroid(2)).^2 < (0.93*r_c)^2;

text_best = disk_in & ~red_mask;
text_best = imopen(text_best, strel('disk', 1));
% Region-based: predicate P(Ri) ตัดจุดรบกวนที่เล็กกว่า 10% ของบริเวณที่ใหญ่สุด
cc = bwconncomp(text_best);
if cc.NumObjects > 0
    areas = cellfun(@numel, cc.PixelIdxList);
    text_best = ismember(labelmatrix(cc), find(areas > 0.10 * max(areas)));
end

[rr, cc2] = find(text_best);
if ~isempty(rr)
    rmin = min(rr); rmax = max(rr); cmin = min(cc2); cmax = max(cc2);
    text_crop = text_best(rmin:rmax, cmin:cmax);
    box_best  = [cmin + roi_circle(1) - 1, rmin + roi_circle(2) - 1, ...
                 cmax - cmin + 1, rmax - rmin + 1];
else
    text_crop = text_best;
    box_best  = [95, 235, 100, 40];
end
final_best = padarray(imresize(~text_crop, 1.5), [25 25], 1, 'both');

%% 4. WORLD'S & DONUTS : คลี่วงแหวน -> segmentation -> OCR
strip_worlds = unwrap_ring(f_sign, cx, cy, r_out, r_in, th_worlds(1), th_worlds(2), H_strip, W_strip);
strip_donuts = unwrap_ring(f_sign, cx, cy, r_in, r_out, th_donuts(1), th_donuts(2), H_strip, W_strip);
box_worlds   = arc_bbox(cx, cy, r_in, r_out, th_worlds);
box_donuts   = arc_bbox(cx, cy, r_in, r_out, th_donuts);

lexW = ''; lexD = '';
if USE_LEXICON, lexW = 'WORLD''S'; lexD = 'DONUTS'; end
% WORLD'S: ลองหลายมุมเริ่มต้น เผื่อตัว W ถูกตัดที่ขอบซ้ายของ strip
best_c = -inf;
for a0 = [172 176 180 184 188]
    s = unwrap_ring(f_sign, cx, cy, r_out, r_in, a0, th_worlds(2), H_strip, W_strip);
    [w, c, img] = ring_ocr(s, k_list, charset, '[^a-zA-Z'']', 4, lexW, se_ring, VERBOSE, sprintf('WORLDS a0=%d', a0));
    if c > best_c
        best_c = c; word_worlds = w; conf_worlds = c; final_worlds = img;
        strip_worlds = s; th_worlds(1) = a0;
    end
end
box_worlds = arc_bbox(cx, cy, r_in, r_out, th_worlds);
[word_donuts, conf_donuts, final_donuts] = ring_ocr(strip_donuts, k_list, charset, '[^a-zA-Z]',   4, lexD, se_ring, VERBOSE, 'DONUTS');

%% 5. แสดงขั้นตอนตามสไลด์
if DEBUG
    % (ก) Hough transform เหมือนสไลด์ line_segment.m
    figure('Name', 'Part II: Canny + Hough (OPEN)', 'NumberTitle', 'off');
    subplot(1,3,1); imshow(e_open); title('Canny edge');
    subplot(1,3,2); imshow(H_h, [], 'XData', theta_h, 'YData', rho_h, 'InitialMagnification', 'fit');
    axis on; axis normal; hold on; xlabel('\theta'); ylabel('\rho');
    if ~isempty(peaks_h)
        plot(theta_h(peaks_h(:,2)), rho_h(peaks_h(:,1)), 's', 'Color', 'w');
    end
    title(sprintf('Hough (skew = %.2f deg)', alpha));
    subplot(1,3,3); imshow(e_open); hold on; title('houghlines');
    for k = 1:numel(lines_h)
        xy = [lines_h(k).point1; lines_h(k).point2];
        plot(xy(:,1), xy(:,2), 'LineWidth', 3, 'Color', [.6 .6 .6]);
    end

    % (ข) Local thresholding เหมือนสไลด์ rice.tif
    figure('Name', 'Part II: Local thresholding (OPEN)', 'NumberTitle', 'off');
    subplot(2,2,1); imshow(c8_open);  title('f : red chroma');
    subplot(2,2,2); imshow(bg_open);  title('f_o = imopen(f, se)');
    subplot(2,2,3); imshow(top_open, []); title(sprintf('top-hat (T = %.1f)', T_open));
    subplot(2,2,4); imshow(bw_open);  title('g (binary)');

    % (ค) Geometry
    figure('Name', 'DEBUG Geometry', 'NumberTitle', 'off');
    imshow(f_sign); hold on;
    viscircles([cx cy], r_in,  'Color', 'g', 'LineWidth', 1);
    viscircles([cx cy], r_out, 'Color', 'b', 'LineWidth', 1);
    rectangle('Position', roi_circle, 'EdgeColor', 'y', 'LineWidth', 1.5);
    rectangle('Position', box_best,   'EdgeColor', 'c', 'LineWidth', 1.5);
    for a = [th_worlds, th_donuts]
        plot(cx + [r_in r_out]*cosd(a), cy - [r_in r_out]*sind(a), 'm-', 'LineWidth', 2);
    end
    title('DEBUG: เขียว/น้ำเงิน = ขอบวงแหวน, ม่วง = มุมเริ่ม-จบ');
    hold off;
end

%% 5. แสดงรูปภาพขั้นตอน Preprocessing ทุกขั้นตอน (Figure 1 สำหรับใส่สไลด์)
figure('Name', 'Preprocessing Pipeline (Test Case 7: Image15.jpg)', 'NumberTitle', 'off');
subplot(2, 3, 1); imshow(f);           title('(1) Original Scene (Image15.jpg)');
subplot(2, 3, 2); imshow(f_sign);      title('(2) Cropped Signboard (ROI)');
subplot(2, 3, 3); imshow(final_open);   title('(3) OPEN Binarized Mask');
subplot(2, 3, 4); imshow(final_best);   title('(4) BEST Binarized Mask');
subplot(2, 3, 5); imshow(final_worlds); title('(5) WORLD''S Unwrapped Strip');
subplot(2, 3, 6); imshow(final_donuts); title('(6) DONUTS Unwrapped Strip');

%% 6. OCR OPEN + BEST แล้วรวมผล
res_open = ocr(final_open, 'LayoutAnalysis', 'block', 'CharacterSet', charset);
res_best = ocr(final_best, 'LayoutAnalysis', 'block', 'CharacterSet', charset);

words = {}; bboxes = []; confidences = [];

for i = 1:length(res_open.Words)
    w_clean = regexprep(strtrim(res_open.Words{i}), '[^a-zA-Z]', '');
    box  = res_open.WordBoundingBoxes(i, :);
    conf = res_open.WordConfidences(i);
    if length(w_clean) >= 3 && conf > 0.50
        box_real = [(box(1)-25) + roi_open(1), (box(2)-25) + roi_open(2), box(3), box(4)];
        words{end+1} = w_clean;                  %#ok<SAGROW>
        bboxes = [bboxes; box_real];             %#ok<AGROW>
        confidences = [confidences; conf];       %#ok<AGROW>
    end
end

[word_best, conf_best] = collect_word(res_best, '[^a-zA-Z]');
if USE_LEXICON && ~isempty(word_best) && lev(word_best, 'BEST') <= 2
    word_best = 'BEST';
end

cand = {word_best,   conf_best,   box_best;
        word_worlds, conf_worlds, box_worlds;
        word_donuts, conf_donuts, box_donuts};
for k = 1:size(cand, 1)
    if length(cand{k,1}) >= 2
        words{end+1} = cand{k,1};                %#ok<SAGROW>
        confidences  = [confidences; cand{k,2}]; %#ok<AGROW>
        bboxes       = [bboxes; cand{k,3}];      %#ok<AGROW>
    end
end

%% 7. แสดงผล Bounding Box แยกเป็น 2 รูป (Figure 2 สำหรับใส่สไลด์)
figure('Name', 'OCR Detection Results (Test Case 7: Image15.jpg)', 'NumberTitle', 'off');

% --- รูปที่ 1: แสดง Bounding Box พร้อม "ข้อความที่อ่านได้ (Recognized Words)" ---
subplot(1, 2, 1);
imshow(f_sign); hold on;
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
imshow(f_sign); hold on;
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

%% 8. แสดงตารางสรุปผลการทดลองใน Command Window
groundTruth = {'OPEN', 'BEST', 'WORLD''S', 'DONUTS'};

fprintf('\n=========================================================================\n');
fprintf('                 ตารางสรุปผลการทดลองของภาพ Test Case 7 (Image15.jpg)\n');
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
end
fprintf('=========================================================================\n');

%% ========================= Local functions ===============================
function c = red_chroma(img)
% R/(R+G+B) : ฟีเจอร์สีแดงที่ไม่ไวต่อความสว่าง/เงา
    R = double(img(:,:,1)); G = double(img(:,:,2)); B = double(img(:,:,3));
    c = R ./ (R + G + B + 1e-5);
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

function [alpha, e, H, theta, rho, peaks, lines] = estimate_skew(bw)
% Canny -> Hough -> มุมเอียงเฉลี่ย (median) ของเส้นที่เกือบแนวนอน
% ใน MATLAB เส้นแนวนอนมี theta ~ +-90 deg
    e = edge(bw, 'canny');
    [H, theta, rho] = hough(e, 'RhoResolution', 0.5);
    peaks = houghpeaks(H, 10);
    lines = houghlines(e, theta, rho, peaks, 'FillGap', 10, 'MinLength', 30);
    a = [];
    for k = 1:numel(lines)
        t = lines(k).theta;
        if t > 0, ak = t - 90; else, ak = t + 90; end
        if abs(ak) < 10, a(end+1) = ak; end %#ok<AGROW>
    end
    if isempty(a), alpha = 0; else, alpha = median(a); end
end

function strip = unwrap_ring(img, cx, cy, r_start, r_end, th_start_deg, th_end_deg, H, W)
% คลี่วงแหวน: แถวบน = r_start, แถวล่าง = r_end, ซ้าย->ขวา = th_start -> th_end
    r  = linspace(r_start, r_end, H);
    th = deg2rad(linspace(th_start_deg, th_end_deg, W));
    [Th, R] = meshgrid(th, r);
    X = cx + R .* cos(Th);
    Y = cy - R .* sin(Th);
    strip = zeros(H, W, 3, 'uint8');
    for c = 1:3
        strip(:,:,c) = uint8(interp2(double(img(:,:,c)), X, Y, 'linear', 255));
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

function bw2 = split_merged(bw, wFactor, hmin)
% Watershed + distance transform (สไลด์ Part II) แยกตัวอักษรที่ติดกัน
% ใช้เฉพาะบริเวณที่กว้างกว่า wFactor เท่าของค่ามัธยฐาน เพราะ watershed ตรง ๆ
% จะตัดตัวอักษรปกติเป็นชิ้น ๆ (เหมือน over-segmentation ในสไลด์)
    bw2 = bw;
    cc = bwconncomp(bw);
    if cc.NumObjects < 3, return; end
    st = regionprops(cc, 'BoundingBox', 'PixelIdxList');
    widths  = arrayfun(@(s) s.BoundingBox(3), st);
    heights = arrayfun(@(s) s.BoundingBox(4), st);
    tall = heights >= 0.5 * size(bw, 1);          % นับเฉพาะชิ้นที่สูงเท่าตัวอักษร
    if nnz(tall) < 3, return; end
    medw = median(widths(tall));
    for k = 1:numel(st)
        if tall(k) && widths(k) > wFactor * medw
            m = false(size(bw)); m(st(k).PixelIdxList) = true;
            D = -bwdist(~m);
            D = imhmin(D, hmin);          % ลด over-segmentation
            D(~m) = -Inf;
            L = watershed(D);
            bw2(m & (L == 0)) = false;
        end
    end
end

function [word, conf, bestImg] = ring_ocr(strip, k_list, charset, pattern, minLen, lexWord, se_r, verbose, tag)
% segmentation ของ strip: top-hat (local) + iterative threshold (global) x k
% -> predicate กรองบริเวณ -> watershed แยกตัวติดกัน -> OCR แล้วเลือกผลที่ดีที่สุด
    Hs = size(strip, 1);
    chroma = imgaussfilt(red_chroma(strip), 1);
    c8  = uint8(255 * mat2gray(chroma));
    top = imtophat(c8, strel('disk', se_r));
    T0  = iter_thresh(top);

    word = ''; conf = 0; bestImg = []; bestScore = -inf; lastImg = [];
    for k = k_list
        bw = top >= k * T0;
        bw = imclose(bw, strel('disk', 1));
        bw = filter_regions(bw, 0.20 * Hs, 0.95 * Hs, 40);
        bw = split_merged(bw, 2.0, 2);
        img = padarray(~bw, [20 20], 1, 'both');
        lastImg = img;

        res = ocr(img, 'LayoutAnalysis', 'block', 'CharacterSet', charset);
        [w, c] = collect_word(res, pattern);
        if verbose
            cch = res.CharacterConfidences; cch = cch(~isnan(cch));
            if isempty(cch), mc = NaN; else, mc = mean(cch); end
            fprintf('[%s] k=%.1f  word=%-10s  wordConf=%.4f  meanCharConf=%.4f\n', tag, k, w, c, mc);
        end
        if length(w) < minLen, continue; end

        if isempty(lexWord)
            score = c - 0.001 * abs(k - 1);        % ถ้า confidence เท่ากัน ให้เลือก k ใกล้ 1
        else
            score = -lev(w, lexWord) + c;
        end
        if score > bestScore
            bestScore = score; word = w; conf = c; bestImg = img;
        end
    end
    if isempty(bestImg), bestImg = lastImg; end
    if ~isempty(lexWord) && ~isempty(word) && lev(word, lexWord) <= 2
        word = lexWord;
    end
end

function box = arc_bbox(cx, cy, r_in, r_out, th_deg)
    th = deg2rad(linspace(th_deg(1), th_deg(2), 200));
    r  = [r_in, r_out];
    X = cx + r(:) * cos(th);
    Y = cy - r(:) * sin(th);
    box = [min(X(:)), min(Y(:)), max(X(:))-min(X(:)), max(Y(:))-min(Y(:))];
end

function [wd, cf] = collect_word(res, pattern)
    wd = ''; cf = 0; n = 0;
    for i = 1:length(res.Words)
        w = regexprep(strtrim(res.Words{i}), pattern, '');
        if ~isempty(w)
            wd = [wd, w];                          %#ok<AGROW>
            cf = cf + res.WordConfidences(i);
            n  = n + 1;
        end
    end
    cf = cf / max(n, 1);
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