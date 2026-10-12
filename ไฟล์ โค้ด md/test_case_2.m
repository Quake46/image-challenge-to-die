%% =========================================================================
% Image Processing Challenge 05: Scene Text Detection & Recognition
% Test Case 2: ภาพ 151.jpg (ป้าย Warehouse Office)
% - แยก Bounding Box เป็น 2 รูป: (1) แสดงข้อความ (2) แสดงค่า Confidence
% - อิงตามทฤษฎีในสไลด์ Part II: Global Thresholding & Morphological Opening
% =========================================================================
clear all; close all; clc;

%% 1. อ่านภาพต้นฉบับ
f = imread('151.jpg');

%% 2. Preprocessing Step (สไลด์ Part I & II)

% --- Step 1: สกัดบริเวณแผ่นป้าย (Crop ROI) และขยายขนาด 2 เท่า ---
roi_sign = [183, 160, 225, 76];
f_sign = imcrop(f, roi_sign);
f_sign = imresize(f_sign, 2);                      % ขยายขนาด 2 เท่า
f_sign_gray = rgb2gray(f_sign);

% --- Step 2: ปรับความคมชัด (CLAHE: adapthisteq) ---
f_adj = adapthisteq(f_sign_gray, 'ClipLimit', 0.02);

% --- Step 3: Segmentation ด้วย Global Thresholding (สไลด์ Part II: หน้า 20-22) ---
T = graythresh(f_adj);
bw_text = imbinarize(f_adj, T);

% --- Step 4: Morphological Opening ลบ Noise เม็ดเล็กๆ (สไลด์ Part II: หน้า 24) ---
se = strel('disk', 1);
bw_clean = imopen(bw_text, se);

% --- Step 5: ปรับสีตัวหนังสือดำบนพื้นขาว สำหรับ OCR ---
final_ocr_input = ~bw_clean;

%% 3. แสดงรูปภาพขั้นตอน Preprocessing ทุกขั้นตอน (Figure 1 สำหรับใส่สไลด์)
figure('Name', 'Preprocessing Pipeline (Test Case 2: 151.jpg)', 'NumberTitle', 'off');
subplot(2, 3, 1); imshow(f);               title('(1) Original Scene (151.jpg)');
subplot(2, 3, 2); imshow(f_sign);          title('(2) Cropped Signboard (ROI 2x)');
subplot(2, 3, 3); imshow(f_adj);           title('(3) Contrast Enhanced (CLAHE)');
subplot(2, 3, 4); imshow(bw_text);         title('(4) Otsu Thresholding (Part II)');
subplot(2, 3, 5); imshow(bw_clean);        title('(5) Morphological Opening (Part II)');
subplot(2, 3, 6); imshow(final_ocr_input); title('(6) Inverted for OCR Input');

%% 4. รัน OCR (อ่านแยกคำตามช่องว่างจริง)
results = ocr(final_ocr_input, 'LayoutAnalysis', 'block');

%% 5. กรองเฉพาะ "คำ" ที่อ่านได้จริง
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
    
    if length(cleanW) >= 2 && box(4) >= 12
        words{end+1} = cleanW;
        bboxes = [bboxes; box];
        confidences = [confidences; conf];
    end
end

%% 6. แสดงผล Bounding Box แยกเป็น 2 รูป (Figure 2 สำหรับใส่สไลด์)
figure('Name', 'OCR Detection Results (Test Case 2)', 'NumberTitle', 'off');

% --- รูปที่ 1: แสดง Bounding Box พร้อม "ข้อความที่อ่านได้" ---
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

% --- รูปที่ 2: แสดง Bounding Box พร้อม "ค่าความเชื่อมั่น" ---
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
groundTruth = {'Drivers', 'stop', 'here', 'and', 'report', 'to', 'Warehouse', 'Office'};

fprintf('\n=========================================================================\n');
fprintf('                 ตารางสรุปผลการทดลองของภาพ Test Case 2 (151.jpg)\n');
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
