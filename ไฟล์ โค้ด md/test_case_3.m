%% =========================================================================
% Image Processing Challenge 05: Scene Text Detection & Recognition
% Test Case 3: ภาพ 217.jpg (ป้ายหน้าร้าน HAIR บนกระจก)
% - แยก Bounding Box เป็น 2 รูป: (1) แสดงข้อความ (2) แสดงค่า Confidence
% - อิงตามทฤษฎีในสไลด์ Part I & II
% =========================================================================
clear all; close all; clc;

%% 1. อ่านภาพต้นฉบับ
f = imread('217.jpg');

%% 2. Preprocessing Pipeline (สไลด์ Part I & II)

% --- Step 1: สกัดบริเวณข้อความ (Crop ROI) พร้อมเว้นระยะขอบรอบทิศทาง ---
roi_text = [20, 200, 600, 210];
f_crop = imcrop(f, roi_text);
f_gray = rgb2gray(f_crop);

% --- Step 2: ปรับความคมชัด (CLAHE: adapthisteq) ---
f_adj = adapthisteq(f_gray, 'ClipLimit', 0.02);

% --- Step 3: Segmentation ด้วย Otsu Thresholding (สไลด์ Part II: หน้า 20-22) ---
T = graythresh(f_adj);
bw_raw = imbinarize(f_adj, T);

% --- Step 4: Morphological Cleaning (สไลด์ Part II: หน้า 24) ---
bw_clean = bwareaopen(bw_raw, 300);

% --- Step 5: ปรับสีตัวหนังสือดำบนพื้นขาว พร้อมเติมขอบขาว (Padding) สำหรับ OCR ---
bw_ocr = ~bw_clean;
pad_size = 30;
final_ocr_input = padarray(bw_ocr, [pad_size pad_size], 1, 'both');

%% 3. แสดงรูปภาพขั้นตอน Preprocessing ทุกขั้นตอน (Figure 1 สำหรับใส่สไลด์)
figure('Name', 'Preprocessing Pipeline (Test Case 3: 217.jpg)', 'NumberTitle', 'off');
subplot(2, 3, 1); imshow(f);               title('(1) Original Scene (217.jpg)');
subplot(2, 3, 2); imshow(f_crop);          title('(2) Cropped Text Region (ROI)');
subplot(2, 3, 3); imshow(f_adj);           title('(3) Contrast Enhanced (CLAHE)');
subplot(2, 3, 4); imshow(bw_raw);          title('(4) Otsu Thresholding (Part II)');
subplot(2, 3, 5); imshow(bw_clean);        title('(5) Morphological Clean (Part II)');
subplot(2, 3, 6); imshow(final_ocr_input); title('(6) Inverted with Padding for OCR');

%% 4. รัน OCR บนภาพที่ผ่านการ Preprocessing
results = ocr(final_ocr_input, 'LayoutAnalysis', 'block');

%% 5. สกัดและประมวลผลคำที่อ่านได้
words = {};
bboxes = [];
confidences = [];

valid_indices = [];
for i = 1:length(results.Words)
    w_clean = regexprep(results.Words{i}, '[^a-zA-Z]', '');
    if ~isempty(w_clean)
        valid_indices = [valid_indices; i];
    end
end

if ~isempty(valid_indices)
    combined_word = '';
    min_x = Inf; min_y = Inf; max_x = 0; max_y = 0;
    conf_sum = 0;
    
    for k = 1:length(valid_indices)
        idx = valid_indices(k);
        w_part = regexprep(results.Words{idx}, '[^a-zA-Z]', '');
        combined_word = [combined_word, w_part];
        
        box = results.WordBoundingBoxes(idx, :);
        box(1) = box(1) - pad_size;
        box(2) = box(2) - pad_size;
        
        min_x = min(min_x, box(1));
        min_y = min(min_y, box(2));
        max_x = max(max_x, box(1) + box(3));
        max_y = max(max_y, box(2) + box(4));
        
        conf_sum = conf_sum + results.WordConfidences(idx);
    end
    
    words{1} = combined_word;
    bboxes = [min_x, min_y, (max_x - min_x), (max_y - min_y)];
    confidences = [conf_sum / length(valid_indices)];
end

%% 6. แสดงผล Bounding Box แยกเป็น 2 รูป (Figure 2 สำหรับใส่สไลด์)
figure('Name', 'OCR Detection Results (Test Case 3)', 'NumberTitle', 'off');

% --- รูปที่ 1: แสดง Bounding Box พร้อม "ข้อความที่อ่านได้" ---
subplot(1, 2, 1);
imshow(f_crop); hold on;
title('1. Bounding Box: ข้อความที่อ่านได้ (Recognized Word: HAIR)');
for i = 1:length(words)
    box = bboxes(i, :);
    w = words{i};
    rectangle('Position', box, 'EdgeColor', 'g', 'LineWidth', 2);
    text(box(1), max(box(2)-12, 12), w, ...
        'Color', 'y', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', 'k', 'Margin', 2, 'Interpreter', 'none');
end
hold off;

% --- รูปที่ 2: แสดง Bounding Box พร้อม "ค่าความเชื่อมั่น" ---
subplot(1, 2, 2);
imshow(f_crop); hold on;
title('2. Bounding Box: ค่าความเชื่อมั่น (Word Confidence)');
for i = 1:length(words)
    box = bboxes(i, :);
    conf = confidences(i);
    rectangle('Position', box, 'EdgeColor', 'g', 'LineWidth', 2);
    text(box(1), max(box(2)-12, 12), sprintf('%.4f', conf), ...
        'Color', 'c', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', 'k', 'Margin', 2, 'Interpreter', 'none');
end
hold off;

%% 7. แสดงตารางสรุปผลการทดลองใน Command Window
groundTruth = {'HAIR'};

fprintf('\n=========================================================================\n');
fprintf('                 ตารางสรุปผลการทดลองของภาพ Test Case 3 (217.jpg)\n');
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
