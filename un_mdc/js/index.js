vm = new Vue({
    el : "#app",
    data : {
        hamburger : false,
        page : "login",
        tabshow : "Kişisel",
        menulist : [
            {title : "Sorgula"   , icon : "fas fa-search", page : "question"},
            {title : "Arananlar" , icon : "fas fa-exclamation-circle", page : "wanteds"},
            {title : "Ekle"      , icon : "fas fa-plus", page : "add"},
        ],
        tablist : [
            {title : "Kişisel" , class : "ontab" , name : "Arda Ahmet Dönmez" , phone: "5551112233" , race : "Beyaz", weight : 100 , height : 180 , age : 26 , money : '17800$'},
            {title : "Araçlar" , class : "", vehicles  : []},
            {title : "Mülkler" , class : "", interiors : []},
            {title : "Geçmiş"  , class : "", records   : []},
        ],
        wanteds : [
            //{rank : 1 , name : 'Arda' , crime : '' , date : ''}
        ]
    },
    methods : {
        changeTab : function(){
            this.tablist.forEach(function(item){
                item.class = "";
            });
        }
    },
    watch : {
        hamburger : function(val){
            if(val){
                document.getElementById("menu").style.width = "140px";
            }
            else{
                document.getElementById("menu").style.width = "0px";
            }
        }
    }
});