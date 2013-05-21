function func_write_matrix_3D(filename,matrix)
    fid = fopen(filename,'w');
        fwrite(fid, matrix);
    fclose(fid);
end

