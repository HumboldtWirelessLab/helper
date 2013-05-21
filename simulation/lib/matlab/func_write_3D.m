function func_write_3D(matrix)
    fid = fopen('nine.bin','w');
        fwrite(fid, matrix);
    fclose(fid);
end

