
% [1] Getting feature vector for Class 1 (BabyDiscomfort)
path = fullfile('Baby Database/BabyDiscomfort/');
files = dir(strcat(path,'*.wav'));
class1 = cell(1,length(files));
for f=1:length(files)
        if (~isempty(strfind(files(f).name,'wav')))
            [data,fs] = audioread(fullfile(path,files(f).name));
            class1{f} = mean(melcepst(data));
        end
end

% [2] Getting feature vector for Class 2 (BabyHungry)
path = fullfile('Baby Database/BabyHungry/');
files = dir(strcat(path,'*.wav'));
class2 = cell(1,length(files));
for f=1:length(files)
        if (~isempty(strfind(files(f).name,'wav')))
            [data,fs] = audioread(fullfile(path,files(f).name));
            class2{f} = mean(melcepst(data));
        end
end

% [3] Getting our Training Set and labels
trainset = cell(1,length(class1)+length(class2));
labels = cell(1,length(class1)+length(class2));
for t=1:length(class1)
    trainset{t} = class1{t};
    labels{t} = 'Discomfort';
    idx = t;
end

for t=1:length(class2)
    trainset{idx+t} = class2{t};
    labels{idx+t} = 'Hungry';
end


% [4] Reading input voice & classify it
y_test = cell(1,length(trainset));
y_pred = cell(1,length(trainset));
path = fullfile('test_samples/');
files = dir(strcat(path,'*.wav'));
for f=1:length(files)
    if (~isempty(strfind(files(f).name,'wav')))
            [y,fs] = audioread(fullfile(path,files(f).name));
            c = mean(melcepst(y));
            if strfind(files(f).name, 'dc')
                y_test{f} =  0;
            else if strfind(files(f).name, 'hungry')
                y_test{f} = 1;
                end
            end
    end
    
    L1_distance = [];
    my_result = [];

    for i = 1:length(trainset)
        L1_distance = [L1_distance ; (c - cell2mat(trainset(i)))];
    end

    for i=1:length(trainset)
        my_result = [my_result ; sum(L1_distance(i,:))];
    end

    c1 = abs(my_result(1:length(class1)));
    c2 = abs(my_result((length(class1)+1:length(class2))));

    sorted_my_result= sort(abs(my_result));
    k_3 = sorted_my_result(1:3);

    c1_count =0;
    c2_count = 0;
    for i=1:3
        if ismember(k_3(i),c1)
            c1_count = c1_count + 1;
        else
            c2_count = c2_count + 1;
        end
    end

    if c1_count > c2_count
        disp(strcat('Discomfort', '--', files(f).name))
        y_pred{f} = 0;
    else
        disp(strcat('Hungry', '--', files(f).name))
        y_pred{f} = 1;
    end
 
end

plotconfusion(y_test(1:80),y_pred(1:80))
figure
plotroc(y_test(1:80),y_pred(1:80))
x_c1 = cell(1,length(class1)) 
y_c1 = cell(1,length(class1)) 
x_c2 = cell(1,length(class2)) 
y_c2 = cell(1,length(class2))
for i=1:length(x_c1)
    x_c1{i} = class1{1,i}(3)
    y_c1{i} = class1{1,i}(5)
end
for i=1:length(x_c2)
    x_c2{i} = class2{1,i}(3)
    y_c2{i} = class2{1,i}(5)
end
figure


% Plot first class
scatter(cell2mat(x_c2),cell2mat(y_c2),'b','*')
% Plot second class.
hold on;
x1=scatter(cell2mat(x_c1),cell2mat(y_c1),'r')
