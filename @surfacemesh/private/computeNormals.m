function normal = computeNormals(dom)

if ( isempty(dom) )
    normal = [];
    return
end

normal = cell(length(dom), 1);

for k = 1:length(dom)
    xu = dom.xu{k}; xv = dom.xv{k};
    yu = dom.yu{k}; yv = dom.yv{k};
    zu = dom.zu{k}; zv = dom.zv{k};
    [nv, nu] = size(xu);
    normal{k} = zeros(nv, nu, 3);
    normal{k}(:,:,1) = yu.*zv - zu.*yv;
    normal{k}(:,:,2) = zu.*xv - xu.*zv;
    normal{k}(:,:,3) = xu.*yv - yu.*xv;
    scl = sqrt(normal{k}(:,:,1).^2 + normal{k}(:,:,2).^2 + normal{k}(:,:,3).^2);
    normal{k} = normal{k} ./ scl;
end

normal = orient(normal, dom);

end

function normal = orient(normal, dom)

% Orient all normal vectors in the same direction
x = dom.x;
y = dom.y;
z = dom.z;
[nv, nu] = size(dom.x{1});
corners = [1 1; nv 1; 1 nu; nv nu];
cidx = sub2ind([nv nu], corners(:,1), corners(:,2));
cidx = cidx(:);

processed = false(length(normal), 1);
processed(1) = true;
queue = 1;
while ( ~isempty(queue) )
    k = queue(1);
    queue(1) = [];
    xk = [x{k}(cidx) y{k}(cidx) z{k}(cidx)];
    % Find the matching point
    for j = 1:length(dom)
        if ( j == k ), continue, end
        if ( ~processed(j) )
            xj = [x{j}(cidx) y{j}(cidx) z{j}(cidx)];
            [lia, locb] = myismember(xj, xk);
            if ( any(lia) )
                l = find(lia, 1);
                cj = corners(l,:);
                ck = corners(locb(l),:);
                if ( dot(normal{j}(cj(1),cj(2),:), normal{k}(ck(1),ck(2),:)) + 1 < 1e-12 )
                    normal{j} = -normal{j};
                end
                processed(j) = true;
                queue(end+1) = j;
            end
        end
    end
end

% Now all vectors are pointing either inward or outward.
% Make them point outward by checking the sign of the volume.
wu = chebtech2.quadwts(nu); wu = wu(:);
wv = chebtech2.quadwts(nv); wv = wv(:);
V = 0;
for k = 1:length(dom)
    I = (dom.x{k} .* normal{k}(:,:,1) + ...
         dom.y{k} .* normal{k}(:,:,2) + ...
         dom.z{k} .* normal{k}(:,:,3)) / 3;
    V = V + sum(sum(I .* wv .* wu.' .* sqrt(dom.J{k})));
end

if ( V < 0 )
    for k = 1:length(dom)
        normal{k} = -normal{k};
    end
end

end

function [lia, locb] = myismember(a, b)
% This is a replacement for: [lia, locb] = ismember(a, b, 'rows')

n = size(a, 1);
lia = false(n, 1);
locb = zeros(n, 1);
for k = 1:n
    s = all(a(k,:) == b, 2);
    lia(k) = any(s);
    if ( lia(k) )
        locb(k) = find(s, 1);
    end
end

end
