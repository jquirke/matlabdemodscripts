function decoded = lte_tailbite_dec(d0, d1, d2)
    
    inputdata = zeros(1,3*length(d0));
    inputdata(1:3:end) = d0;
    inputdata(2:3:end) = d1;
    inputdata(3:3:end) = d2;
    
    trellis = poly2trellis([7], [133 171 165]); 
    
    decoded = vitdec([inputdata inputdata], trellis, min(length(d0),70), 'trunc', 'hard');
    
    decoded = decoded(length(decoded)/2+1:end);
    
end
