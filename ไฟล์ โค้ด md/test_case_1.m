%% =========================================================================
% Test Case 1
% =========================================================================
clear all; close all; clc;

%% 1. อ่านภาพต้นฉบับ
f = imread('100.jpg');

%% 2. ขั้นตอน Preprocessing (สไลด์ Part I & II)

% --- Step 2.1: แปลงภาพต้นฉบับเป็น Grayscale ---
f_gray_full = rgb2gray(f);

% --- Step 2.2: สกัดแผ่นป้าย (Signboard Segmentation) ---
bw_sign = f_gray_full > 120;
stats = regionprops(bw_sign, 'Area', 'BoundingBox');
[~, maxIdx] = max([stats.Area]);
roi = stats(maxIdx).BoundingBox;

% --- Step 2.3: ตัดเฉพาะแผ่นป้าย (Crop ROI - ตัดเส้นขอบดำรอบป้ายออก 15 px) ---
margin = 15;
roi_inner = [roi(1)+margin, roi(2)+margin, roi(3)-2*margin, roi(4)-2*margin];
f_sign = imcrop(f, roi_inner);
f_sign_gray = rgb2gray(f_sign);

% --- Step 2.4: ปรับคอนทราสต์ให้ตัวหนังสือคมชัด (CLAHE: adapthisteq) ---
f_adj = adapthisteq(f_sign_gray, 'ClipLimit', 0.02);

% --- Step 2.5: ลดสัญญาณรบกวนพื้นผิว (Median Filter: medfilt2) ---
f_clean = medfilt2(f_adj, [3 3]);

%% 3. แสดงรูปภาพขั้นตอน Preprocessing ทุกขั้นตอน (Figure 1 สำหรับใส่สไลด์)
figure('Name', 'Preprocessing Pipeline (Test Case 1)', 'NumberTitle', 'off');
subplot(2, 3, 1); imshow(f);           title('(1) Original Image (testcase1.jpg)');
subplot(2, 3, 2); imshow(bw_sign);     title('(2) Signboard Mask (Segmentation)');
subplot(2, 3, 3); imshow(f_sign);      title('(3) Cropped Signboard (ROI)');
subplot(2, 3, 4); imshow(f_sign_gray); title('(4) Cropped Grayscale');
subplot(2, 3, 5); imshow(f_adj);       title('(5) Contrast Enhanced (CLAHE)');
subplot(2, 3, 6); imshow(f_clean);     title('(6) Filtered Image (Ready for OCR)');

%% 4. รัน OCR บนภาพที่ผ่านการ Preprocessing
results = ocr(f_clean, 'LayoutAnalysis', 'block');

%% 5. กรองเฉพาะ "คำ" (ตัดลูกศร จุด และรอยขีดข่วนทิ้ง)
words_all = results.Words;
boxes_all = results.WordBoundingBoxes;
confs_all = results.WordConfidences;

words = {};
bboxes = [];
confidences = [];

for i = 1:length(words_all)
    rawW = strtrim(words_all{i});
    cleanW = regexprep(rawW, '[^a-zA-Z]', '');
    box = boxes_all(i, :);
    conf = confs_all(i);
    
    % เงื่อนไขในการเป็นคำจริง:
    % 1. มีตัวอักษรอย่างน้อย 2 ตัว (ตัดลูกศร '=', รอยขีด '|', จุด '.' ทิ้ง)
    % 2. ความสูงของกล่องต้องได้ขนาดตัวหนังสือจริง (box(4) >= 14 pixels)
    % 3. ตัด 'ge' ทิ้ง (หัวน็อตใต้ป้าย) และตัดวัตถุที่อยู่ขอบล่างใต้ข้อความหลักทิ้ง
    is_bottom_screw = (box(2) > size(f_sign, 1) * 0.82) || strcmpi(cleanW, 'ge');
    if length(cleanW) >= 2 && box(4) >= 14 && ~is_bottom_screw
        words{end+1} = cleanW;
        bboxes = [bboxes; box];
        confidences = [confidences; conf];
    end
end

%% 6. แสดงผล Bounding Box แยกเป็น 2 รูป (Figure 2 สำหรับใส่สไลด์)
figure('Name', 'OCR Detection Results (Test Case 1)', 'NumberTitle', 'off');

% --- รูปที่ 1: แสดง Bounding Box พร้อม "ข้อความที่อ่านได้ (Recognized Text)" ---
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

%% 7. แสดงตารางสรุปผลการทดลองใน Command Window
groundTruth = {'Footpath', 'To', 'Colchester', 'and', 'Greenstead'};

fprintf('\n=========================================================================\n');
fprintf('                 ตารางสรุปผลการทดลองของภาพ Test Case 1\n');
fprintf('=========================================================================\n');
fprintf('%-5s | %-15s | %-12s | %-18s | %-15s\n', ...
    'ลำดับ', 'คำที่ถูกต้อง (GT)', 'Confidence', 'คำที่อ่านได้', 'Recognition Rate');
fprintf('-------------------------------------------------------------------------\n');

totalConf = 0; totalRate = 0; validCount = length(words);

for i = 1:validCount
    recWord = words{i};
    conf = confidences(i);
    
    bestRate = 0; matchedGT = '-';
    for g = 1:length(groundTruth)
        gt = groundTruth{g};
        matchChars = sum(recWord(1:min(end, length(gt))) == gt(1:min(end, length(recWord))));
        rate = (matchChars / max(length(gt), length(recWord))) * 100;
        if rate > bestRate
            bestRate = rate; matchedGT = gt;
        end
    end
    
    totalConf = totalConf + conf;
    totalRate = totalRate + bestRate;
    
    fprintf('%-5d | %-15s | %-12.4f | %-18s | %-14.2f %%\n', ...
        i, matchedGT, conf, recWord, bestRate);
end

fprintf('-------------------------------------------------------------------------\n');
if validCount > 0
    fprintf('ค่าเฉลี่ย:            | Confidence: %-6.4f |                     | Rate: %-6.2f %%\n', ...
        totalConf/validCount, totalRate/validCount);
end
fprintf('=========================================================================\n');
