const jsdom = require('jsdom')
const dom = new jsdom.JSDOM("")
const $ = jQuery = require('jquery')(dom.window);

const url_idcs = "";
const oauthClientId = "";
const oauthClientSecret = "";
var oauth2Token = "";

var payload = [];
var defaultUserData = {
  password: "Password123",
  email: "username@email.com",
  email_type: "work"
}


var userData = [
  {
    "user": "unit_test.account_1",
    "group": ["Generic Group Role", "PRICING_ANALYST_JOB"]
  },
  {
    "user": "unit_test.account_2",
    "group": ["Generic Group Role", "PRICING_APPLICATION_ADMINISTRATOR_JOB"]
  },
  {
    "user": "unit_test.account_3",
    "group": ["Generic Group Role", "PRICING_DATA_STEWARD_JOB"]
  }
];

var api_settings = {
  default: {
    "async": false,
    "timeout": 0,
    "headers": {
      "Content-Type": "application/json"
    }
  },
  oauth2: {
    "url": url_idcs + "/oauth2/v1/token",
    "async": false,
    "method": "POST",
    "headers": {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Basic " + btoa(oauthClientId + ':' + oauthClientSecret)
    },
    "data": {
      "grant_type": "client_credentials",
      "scope": "urn:opc:idm:__myscopes__"
    }
  },
  usersCreate: {
    "url": url_idcs + "/admin/v1/Users",
    "method": "POST",
    "data": [],
  },
  groupsSearch: {
    "url": url_idcs + "/admin/v1/Groups?attributes=id,displayName&filter=displayName ", //eq \"PRICING_ANALYST_JOB_PREPROD\"",
    "method": "GET"
  },
  groupsAddMember: {
    "url": url_idcs + "/admin/v1/Groups/",
    "method": "PATCH",
    "data": []
  }
}

function ajaxError (jqXHR, textStatus, errorThrown) {
  console.error("jqXHR:", jqXHR);
  console.error("textStatus: \"%s\"", textStatus);
  console.error("errorThrown:", errorThrown);

  throw new Error();
}

console.log("Calling \"%s\"", api_settings.oauth2.url)
$.ajax(api_settings.oauth2).done((res) => {
  oauth2Token = res.token_type + " " +  res.access_token;
  api_settings.default.headers.Authorization = oauth2Token;
  //console.log("api default settings: ", JSON.stringify(api_settings.default));
}).fail ((jqXHR, textStatus, errorThrown) => {ajaxError (jqXHR, textStatus, errorThrown)});

$.ajaxSetup(api_settings.default);

console.debug("User data: ", JSON.stringify(userData));
//console.log("Creating payload for Create User API");
$.each(userData, (idx, rec) => {
  //console.log("User: %s   |   Group: %s", rec.user, rec.group)
  payload =
  {
    "schemas": [
      "urn:ietf:params:scim:schemas:core:2.0:User"
    ],
    "name": {
      "formatted": rec.user,
      "familyName": rec.user
    },
    "active": true,
    "userName": rec.user,
    "password": defaultUserData.password,
    "emails": [
      {
        "value": defaultUserData.email,
        "type": defaultUserData.email_type,
        "secondary": false,
        "verified": true,
        "primary": true
      }
    ]
  };
  api_settings.usersCreate.data = JSON.stringify(payload);

  console.log("Calling \"%s\"", api_settings.usersCreate.url)
  $.ajax(api_settings.usersCreate).done((res) => {
    userData[idx].user = {
      "userName": res.userName, //userData[idx].user,
      "id": res.id
    }
  }).fail ((jqXHR, textStatus, errorThrown) => {ajaxError (jqXHR, textStatus, errorThrown)});
  console.log("Working with user \"%s\" (%s)", userData[idx].user.userName, userData[idx].user.id)


  $.each(userData[idx].group, (g, group) => {
    
    // Get group id
    url = {"url": api_settings.groupsSearch.url + 'eq "' + group + "\""};
    console.log("Calling \"%s\"", url.url)
    $.ajax(url, api_settings.groupsSearch).done((res) => {
      userData[idx].group[g] = {
        "displayName": res.Resources[0].displayName,
        "id": res.Resources[0].id
      }
    }).fail ((jqXHR, textStatus, errorThrown) => {ajaxError (jqXHR, textStatus, errorThrown)});


    console.debug("Adding memeber \"%s(%s)\" to group \"%s(%s)\"", userData[idx].user.userName, userData[idx].user.id, userData[idx].group[g].displayName, userData[idx].group[g].id)
    url = {"url": api_settings.groupsAddMember.url + userData[idx].group[g].id };
    payload = {
      "schemas": [
        "urn:ietf:params:scim:api:messages:2.0:PatchOp"
      ],
      "Operations": [
        {
          "op": "add",
          "path": "members",
          "value": [
            {
              "value": userData[idx].user.id,
              "type": "User"
            }
          ]
        }
      ]
    }
    api_settings.groupsAddMember.data = JSON.stringify(payload);
    
    console.debug("Calling \"%s\"", url.url)
    console.debug("------> api_settings.groupsAddMember: ", JSON.stringify(api_settings.groupsAddMember))
    $.ajax(url, api_settings.groupsAddMember).done((res, status) => {
      console.log(res,status, JSON.stringify(userData));
    }).fail ((jqXHR, textStatus, errorThrown) => {ajaxError (jqXHR, textStatus, errorThrown)});
  });
})