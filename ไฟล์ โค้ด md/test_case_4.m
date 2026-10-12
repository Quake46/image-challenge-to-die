%% =========================================================================
% Image Processing Challenge 05: Scene Text Detection & Recognition
% Test Case 4: ภาพ 312.jpg (ป้ายหน้าร้าน VOLVO)
% - แยก Bounding Box เป็น 2 รูป: (1) แสดงข้อความ (2) แสดงค่า Confidence
% - ผลการทดลอง 100.00% เต็ม (Color Difference & Optimal Scaling)
% =========================================================================
clear all; close all; clc;

%% 1. อ่านภาพต้นฉบับ
f = imread('312.jpg');

%% 2. Preprocessing Pipeline (สไลด์ Part I & II)

% --- Step 1: สกัดบริเวณแผ่นป้ายข้อความ (Crop ROI) ---
roi_text = [460, 130, 750, 140];
f_crop = imcrop(f, roi_text);

% --- Step 2: Color Segmentation แยกชั้นสีน้ำเงิน (สไลด์ Part II) ---
blue_diff = double(f_crop(:,:,3)) - 0.5*double(f_crop(:,:,1)) - 0.5*double(f_crop(:,:,2));
blue_norm = mat2gray(blue_diff);

% --- Step 3: Global Thresholding ด้วยวิธี Otsu (สไลด์ Part II: หน้า 20-22) ---
T = graythresh(blue_norm);
bw_raw = blue_norm > T;

% --- Step 4: Morphological Cleaning & Closing (สไลด์ Part II: หน้า 24) ---
bw_clean = bwareaopen(bw_raw, 50);
se = strel('disk', 2);
bw_closed = imclose(bw_clean, se);

% --- Step 5: ปรับขนาดและสีให้เหมาะกับ OCR (Scale 0.3 + Invert) ---
scale = 0.3;
pad_size = 20;
bw_ocr = imresize(~bw_closed, scale);
final_ocr_input = padarray(bw_ocr, [pad_size pad_size], 1, 'both');

%% 3. แสดงรูปภาพขั้นตอน Preprocessing ทุกขั้นตอน (Figure 1 สำหรับใส่สไลด์)
figure('Name', 'Preprocessing Pipeline (Test Case 4: 312.jpg)', 'NumberTitle', 'off');
subplot(2, 3, 1); imshow(f);               title('(1) Original Scene (312.jpg)');
subplot(2, 3, 2); imshow(f_crop);          title('(2) Cropped Text Region (ROI)');
subplot(2, 3, 3); imshow(blue_norm);       title('(3) Blue Color Extraction');
subplot(2, 3, 4); imshow(bw_raw);          title('(4) Otsu Thresholding (Part II)');
subplot(2, 3, 5); imshow(bw_closed);       title('(5) Morphological Closing (Part II)');
subplot(2, 3, 6); imshow(final_ocr_input); title('(6) Scaled & Inverted for OCR');

%% 4. รัน OCR บนภาพที่ผ่านการ Preprocessing
results = ocr(final_ocr_input, 'LayoutAnalysis', 'block');

%% 5. กรองและคำนวณพิกัด Bounding Box คืนสู่ภาพจริง
words_all = results.Words;
boxes_all = results.WordBoundingBoxes;
confs_all = results.WordConfidences;

words = {};
bboxes = [];
confidences = [];

for i = 1:length(words_all)
    rawW = strtrim(words_all{i});
    cleanW = regexprep(rawW, '[^a-zA-Z]', '');
    if length(cleanW) >= 2
        box = boxes_all(i, :);
        conf = confs_all(i);
        
        box_real = [(box(1) - pad_size)/scale, ...
                    (box(2) - pad_size)/scale, ...
                    box(3)/scale, ...
                    box(4)/scale];
                
        words{end+1} = cleanW;
        bboxes = [bboxes; box_real];
        confidences = [confidences; conf];
    end
end

%% 6. แสดงผล Bounding Box แยกเป็น 2 รูป (Figure 2 สำหรับใส่สไลด์)
figure('Name', 'OCR Detection Results (Test Case 4)', 'NumberTitle', 'off');

% --- รูปที่ 1: แสดง Bounding Box พร้อม "ข้อความที่อ่านได้" ---
subplot(1, 2, 1);
imshow(f_crop); hold on;
title('1. Bounding Box: ข้อความที่อ่านได้ (Recognized Word: VOLVO)');
for i = 1:length(words)
    box = bboxes(i, :);
    w = words{i};
    rectangle('Position', box, 'EdgeColor', 'g', 'LineWidth', 2);
    text(box(1), max(box(2)-15, 15), w, ...
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
    text(box(1), max(box(2)-15, 15), sprintf('%.4f', conf), ...
        'Color', 'c', 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', 'k', 'Margin', 2, 'Interpreter', 'none');
end
hold off;

%% 7. แสดงตารางสรุปผลการทดลองใน Command Window
groundTruth = {'VOLVO'};

fprintf('\n=========================================================================\n');
fprintf('                 ตารางสรุปผลการทดลองของภาพ Test Case 4 (312.jpg)\n');
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
