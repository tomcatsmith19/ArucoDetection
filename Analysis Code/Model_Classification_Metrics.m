clc;

prompt = "True Positives (TP): ";
prompt2 = "False Negatives (FN): ";
prompt3 = "False Positives (FP): ";
prompt4 = "True Negatives (TN): ";
TP = input(prompt);
FN = input(prompt2);
FP = input(prompt3);
TN = input(prompt4);
adjusted = 0;

if TP == 0
    TP = (1/(2*FN))*FN;
    FN = FN-TP;
    adjusted = 1;
end
if FN == 0
    FN = (1/(2*TP))*TP;
    TP = TP-FN;
    adjusted = 1;
end
if FP == 0
    FP = (1/(2*TN))*TN;
    TN = TN-FP;
    adjusted = 1;
end
if TN == 0
    TN = (1/(2*FP))*FP;
    FP = FP-TN;
    adjusted = 1;
end

Accuracy = (TP+TN)/(TP+FN+FP+TN)*100;
Precision = (TP)/(TP+FP)*100;
Sensitivity = (TP)/(TP+FN)*100;
Specificity = (TN)/(TN+FP)*100;
F1 = 2*(Precision*Sensitivity)/(Precision+Sensitivity);
D_Prime = norminv(TP/(TP+FN))-norminv(FP/(FP+TN));
MCC = ((TP*TN)-(FP*FN))/(sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN)));

if adjusted == 1
    disp(" ");
    disp("Adjusted True Positives: " + TP);
    disp("Adjusted False Negatives: " + FN);
    disp("Adjusted False Positives: " + FP);
    disp("Adjusted True Negatives: " + TN);
end

disp(" ");
disp("Accuracy: " + Accuracy);
disp("Precision: " + Precision);
disp("Sensitivity: " + Sensitivity);
disp("Specificity: " + Specificity);
disp("F1-Score: " + F1);
disp("D': " + D_Prime);
disp("Matthews Correlation Coefficient: " + MCC);