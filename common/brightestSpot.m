function [pos, color] = brightestSpot(envmap, varargin)
            % Find the brightest spot in an environment map
            %
            %   [pos, color] = brightestSpot(envmap)
            %
            
            minPrctile = 99.99;
            
            parseVarargin(varargin{:});
            
            % work in the angular representation 
            % (won't mess the sky too much)
            envmap = envmap.convertTo('angular');
            
            % but first, blur to avoid finding isolated bright spot
            h = fspecial('gaussian', 5, 5);
            envmapI = imfilter(envmap, h);
            
            % convert to intensity
            envmapI = envmapI.intensity();
            
            % keep everything that's greater than prctile
            % but don't use the data that's = 0
            
            minVal = prctile(envmapI.data(envmapI.data~=0), minPrctile);
            map = envmapI.data >= minVal;
            
            % get (weighted) centroid of largest blob
            props = regionprops(map, {'Area', 'Centroid', 'PixelIdxList'});
            [~,largestInd] = max([props(:).Area]);
            
            w = envmapI.data(props(largestInd).PixelIdxList);
            [r,c] = ind2sub(size(envmapI), props(largestInd).PixelIdxList);
            
            r = min(max(round(sum(r.*w)./sum(w)), 1), envmapI.nrows);
            c = min(max(round(sum(c.*w)./sum(w)), 1), envmapI.ncols);
                                    
            pos = envmapI.image2world(c/envmapI.ncols, ...
                r/envmapI.nrows);
            
            % get the color at that spot
            color = column(envmap.data(r, c, :));
        end
