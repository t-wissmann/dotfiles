// ==UserScript==
// @name         Gitlab artifacts
// @version      0.1
// @description  Get permalinks to artifact files independent of the job ID
// @author       Thorsten Wißmann
// ==/UserScript==
//
// currently, this only works for the master branch.

function addArtifactLink() {
    alert('gitlab');
}

function isGitlab() {
    for (let head of document.getElementsByTagName("head")) {
        for (let meta of document.getElementsByTagName("meta")) {
            if (meta.content == "GitLab") {
                return true;
            }
        }
    }
    return false;
}

function extractJobName() {
    for (let head of document.getElementsByTagName("head")) {
        for (let meta of document.getElementsByTagName("meta")) {
            var m = meta.content.match(/Artifacts [^ ]+ ([^ ]+) \(#/i);
            if (m != undefined) {
                return m[1]
            }
        }
    }
    return undefined;
}

function getPermalinks(jobname) {
    var url = window.location.href;
    // in the url we have to replace the
    //      /-/jobs/JOBNUMBER/artifacts/
    // by
    //      /-/jobs/artifacts/master/
    // and append ?job=JOBNAME
    view_url = url.replace(/\/-\/jobs\/[0-9]+\/artifacts\//i,
                       "/-/jobs/artifacts/master/")
                      + "?job=" + jobname;
    obj = [
        { title: "View",
          url: view_url,
        }
    ]
    if (view_url.search('/file/') >= 0) {
        // if it's a file (and not a dir listing)
        obj.push({
            title: "Raw",
            url: view_url.replace('/file/', '/raw/'),
        });
    }
    return obj
}

function addLinks(links) {
    for (let div of document.getElementsByTagName("div")) {
        if (div.classList.contains("tree-controls")
          || div.classList.contains("file-actions")) {
            for (l of links) {
                var a = document.createElement('a')
                var linkText = document.createTextNode(l.title);
                a.appendChild(linkText);
                a.href = l.url;
                a.classList.add('btn', 'btn-default');
                a.style.marginLeft = '5px';
                div.appendChild(a);
            }
        }
    }
}

/**
 * Main
 */
(function() {
    if (isGitlab()) {
        var jobname = extractJobName()
        if (jobname != undefined) {
            addLinks(getPermalinks(jobname));
        }
    }
})();
