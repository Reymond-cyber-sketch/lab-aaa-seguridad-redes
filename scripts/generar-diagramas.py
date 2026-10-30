"""Genera diagramas documentales; no inspecciona ni configura equipos."""
from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

DEST = Path(__file__).resolve().parents[1] / "imagenes"
DEST.mkdir(parents=True, exist_ok=True)
plt.rcParams.update({"font.family":"DejaVu Sans", "svg.fonttype":"none"})
NAVY="#132b46"; BLUE="#226ab4"; GREEN="#18836f"; GRAY="#65778b"

def base(title, subtitle):
    fig, ax = plt.subplots(figsize=(14,9))
    fig.patch.set_facecolor("#f5f8fc")
    ax.set_facecolor("#f5f8fc")
    ax.set(xlim=(0,1),ylim=(0,1))
    ax.axis("off")
    ax.text(.03,.965,title,fontsize=21,fontweight="bold",color=NAVY,va="top")
    ax.text(.03,.91,subtitle,fontsize=10.8,color=GRAY,va="top")
    fig.subplots_adjust(left=.025,right=.975,top=.98,bottom=.025)
    return fig, ax

def box(ax,x,y,w,h,title,body,color=BLUE,dashed=False):
    p=FancyBboxPatch((x-w/2,y-h/2),w,h,boxstyle="round,pad=0.013,rounding_size=.015",
        facecolor="white",edgecolor=color,linewidth=1.8,linestyle="--" if dashed else "-")
    ax.add_patch(p)
    ax.text(x,y+h*.29,title,ha="center",va="center",fontsize=13,fontweight="bold",color=color)
    ax.text(x,y-h*.11,body,ha="center",va="center",fontsize=10.3,color=NAVY,linespacing=1.6)

def arrow(ax,a,b,label,xy,color=GRAY,style="-",curve=0):
    ax.add_patch(FancyArrowPatch(a,b,arrowstyle="-|>",mutation_scale=15,linewidth=1.8,
        color=color,linestyle=style,connectionstyle="arc3,rad="+str(curve)))
    ax.text(*xy,label,ha="center",va="center",fontsize=9.7,color=color,
        bbox={"facecolor":"#f5f8fc","edgecolor":"none","pad":3},linespacing=1.5)

def save(fig,name):
    fig.savefig(DEST/(name+".png"),dpi=180,facecolor=fig.get_facecolor())
    fig.savefig(DEST/(name+".svg"),facecolor=fig.get_facecolor())
    plt.close(fig)

fig,ax=base("Topología del laboratorio AAA","GNS3 + VMware  |  RouterOS 7.23.7  |  seguridad.test")
box(ax,.17,.78,.25,.14,"NAT1","Salida del laboratorio\nWAN por DHCP")
box(ax,.48,.78,.22,.14,"MGMT-NEW","Cloud sin enlace\nFuera del acceso AAA",GRAY,True)
box(ax,.17,.46,.25,.17,"R1-AAA","LAN: 10.24.96.1/24\nether2 · enrutamiento y NAT")
box(ax,.52,.46,.25,.17,"SW1-AAA","10.24.96.2/24 en BR-AAA\nBridge: ether1, ether2 y ether3")
box(ax,.80,.78,.32,.18,"Servidor AD + NPS","Windows Server 2022\n10.24.96.138/24 · DNS propio\nAD: seguridad.test",GREEN)
box(ax,.82,.21,.27,.13,"USER-PRIV","ether3 de SW1 ↔ eth0\nNodo auxiliar detenido","#a44949",True)
arrow(ax,(.17,.697),(.17,.558),"ether1 de R1\nWAN DHCP",(.255,.628))
arrow(ax,(.307,.46),(.382,.46),"ether2 ↔ ether1",(.345,.53))
arrow(ax,(.565,.557),(.735,.676),"ether2 de SW1 ↔ NIC servidor\nEthernet0 2 · ifIndex 4",(.735,.60),GREEN)
arrow(ax,(.60,.365),(.755,.29),"ether3",(.66,.30),GRAY,"--")
ax.text(.035,.12,"Gateway LAN: 10.24.96.1   ·   Autenticación: UDP 1812   ·   Accounting: UDP 1813",
        fontsize=10.5,color=NAVY)
ax.text(.035,.065,"Diagrama basado en el cableado recibido y los exports. USER-PRIV no participó en las pruebas AAA.",
        fontsize=9.6,color=GRAY)
save(fig,"topologia")

fig,ax=base("Autenticación y autorización","NPS valida la cuenta; RouterOS aplica los permisos del grupo devuelto")
box(ax,.20,.73,.30,.16,"Consola de GNS3","usuario0 / usuario5 / usuario10\nAcceso local al NAS")
box(ax,.71,.73,.34,.16,"NAS: R1 o SW1","Cliente RADIUS de login\nOrigen: 10.24.96.1 o .2")
box(ax,.71,.34,.34,.20,"NPS + Active Directory","10.24.96.138\nGrupo NIVEL-0 / NIVEL-5 / NIVEL-10\nPolítica AAA-NIVEL correspondiente",GREEN)
box(ax,.20,.34,.31,.20,"Autorización en RouterOS","nivel0: consola\nnivel5: lectura y pruebas\nnivel10: lectura y escritura")
arrow(ax,(.365,.73),(.525,.73),"Credenciales de dominio",(.445,.80))
arrow(ax,(.71,.637),(.71,.455),"Solicitud: UDP 1812\nSesión/accounting: UDP 1813",(.55,.55),BLUE)
arrow(ax,(.525,.34),(.37,.34),"Access-Accept\nMikrotik-Group",(.45,.45),GREEN)
arrow(ax,(.20,.455),(.20,.637),"Permisos de la sesión",(.31,.55),BLUE)
ax.text(.035,.13,"Roles de dominio: sin permiso SSH. Gestión SSH demostrada con cuentas locales.",fontsize=10.5,color=NAVY)
ax.text(.035,.07,"Excepción de esta práctica: require-message-auth=no. CHR no aporta AUX independiente.",fontsize=10.2,color=GRAY)
save(fig,"flujo-aaa")
