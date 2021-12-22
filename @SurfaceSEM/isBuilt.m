function out = isBuilt(S)
%ISBUILT   Check to see if a SURFACESEM has been built.

out = numel(S.patches) == 1;

end
