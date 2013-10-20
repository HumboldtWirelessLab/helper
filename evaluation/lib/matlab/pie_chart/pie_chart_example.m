function pie_chart_example()
  a = [ 0.15 0.80, 0.05 ];
  labels = {'Teilzeit','   Vollzeit', 'Rest'};
  explode = [1,0,-4];

  %figure;
  %pie(a,explode,labels)
  
  pie3s(a,'Bevel','None','Explode',explode,'Labels',labels)
  
  %matlab 2013
  %p := plot::Piechart3d(a):
  %plot(p)

   print('pc_none.png','-dpng');

end