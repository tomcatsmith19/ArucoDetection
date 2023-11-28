clc;

prompt = "Hits: ";
prompt2 = "Misses: ";
prompt3 = "False Alarms: ";
prompt4 = "Correct Rejections: ";
hits = input(prompt);
misses = input(prompt2);
falseAlarms = input(prompt3);
correctRejections = input(prompt4);

Accuracy = (hits+correctRejections)/(hits+misses+falseAlarms+correctRejections)*100;
Precision = (hits)/(hits+falseAlarms)*100;
TPR = (hits)/(hits+misses)*100;
TNPR = (correctRejections)/(correctRejections+falseAlarms)*100;
F1 = 2*(Precision*TPR)/(Precision+TPR);
D_Prime = norminv(hits/(hits+misses))-norminv(falseAlarms/(falseAlarms+correctRejections));
MCC = ((hits*correctRejections)-(falseAlarms*misses))/(sqrt((hits+falseAlarms)*(hits+misses)*(correctRejections+falseAlarms)*(correctRejections+misses)));

disp(" ");
disp("Accuracy: " + Accuracy);
disp("Precision: " + Precision);
disp("TPR: " + TPR);
disp("TNPR: " + TNPR);
disp("F1-Score: " + F1);
disp("D': " + D_Prime);
disp("MCC: " + MCC);