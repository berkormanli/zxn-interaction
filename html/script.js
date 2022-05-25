let buttonParams = [];
let menuOpened = false;
let interactionKeyOpened = false;

const interactionKeyDOM = document.getElementsByClassName("circle")[0];

const openMenu = (data = null, coordX, coordY) => {
    //console.log(coordX*100)
    //console.log(coordY*100)
    if (menuOpened) {
        $("#container").css({"left": coordX*100+"vw"})
        $("#container").css({"top": coordY*100+"vh"})
    }
    else {
        let html = "";
        data.forEach((item, index) => {
            if(!item.hidden) {
                let header = item.header;
                let message = item.txt || item.text;
                let isMenuHeader = item.isMenuHeader;
                let isDisabled = item.disabled;
                html += getButtonRender(header, message, index, isMenuHeader, isDisabled);
                if (item.params) buttonParams[index] = item.params;
            }
        });

        $("#container").css({"left": coordX*100+"vw"})
        $("#container").css({"top": coordY*100+"vh"})

        //$("#buttons").html(html);
        $("#buttons").html(html);
        menuOpened = true
        $("#container").removeClass('animation-closeFromMiddle');
        $("#container").addClass('animation-openFromMiddle');


        //menuOpened = true
    
        $('.button').click(function() {
            const target = $(this)
            if (!target.hasClass('title') && !target.hasClass('disabled')) {
                postData(target.attr('id'));
            }
        });
    }
};

const openInteractionKey = (coordX, coordY) => {
    if (interactionKeyOpened) {
        interactionKeyDOM.style.left = coordX*100+"%";
        interactionKeyDOM.style.right = (100 - coordX*100)+"%";
        interactionKeyDOM.style.top = coordY*100+"%";
        interactionKeyDOM.style.bottom = (100 - coordY*100)+"%";
    }
    else {
        interactionKeyDOM.style.left = coordX*100+"%";
        interactionKeyDOM.style.right = (100 - coordX*100)+"%";
        interactionKeyDOM.style.top = coordY*100+"%";
        interactionKeyDOM.style.bottom = (100 - coordY*100)+"%";

        interactionKeyOpened = true;
        interactionKeyDOM.classList.add("fadeIn");
        setTimeout(function(){
            interactionKeyDOM.classList.remove("fadeIn");
            interactionKeyDOM.style.opacity = 1
            console.log("removed fadeIn")
        }, 2000);
    }
}

const getButtonRender = (header, message = null, id, isMenuHeader, isDisabled) => {
    return `
    <div class="${isMenuHeader ? "title" : "button"} ${isDisabled ? "disabled" : ""}" id="${id}">
        <div class="header">${header}</div>
        ${message ? `<div class="text">${message}</div>` : ""}
    </div>
    `;
};

const closeMenu = () => {
    $("#container").removeClass('animation-openFromMiddle');
    $("#container").addClass('animation-closeFromMiddle');
    setTimeout(function(){
        $("#buttons").html(" ");
        menuOpened = false
        buttonParams = [];
    }, 2000);
};

const closeInteractionKey = () => {
    interactionKeyOpened = false;
    interactionKeyDOM.classList.add("fadeOut");
    setTimeout(function(){
        interactionKeyDOM.classList.remove("fadeOut");
        interactionKeyDOM.style.opacity = 0
        console.log("removed fadeOut")
    }, 2000);
};

const postData = (id) => {
    $.post(`https://${GetParentResourceName()}/clickedButton`, JSON.stringify(parseInt(id) + 1));
    return closeMenu();
};

const cancelMenu = () => {
    $.post(`https://${GetParentResourceName()}/closeMenu`);
    return closeMenu();
};



window.addEventListener("message", (event) => {
    const data = event.data;
    const buttons = data.data;
    const coordX = data.coordX;
    const coordY = data.coordY;
    const action = data.action;
    switch (action) {
        case "OPEN_MENU":
        case "SHOW_HEADER":
            return openMenu(buttons, coordX, coordY);
        case "OPEN_KEY":
        case "SHOW_KEY":
            return openInteractionKey(coordX, coordY);
        case "CLOSE_MENU":
            return closeMenu();
        case "CLOSE_KEY":
            return closeInteractionKey();
        default:
            return;
    }
});

document.onkeyup = function (event) {
    const charCode = event.key;
    if (charCode == "Escape") {
        cancelMenu();
    }
};