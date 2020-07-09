// ==UserScript==
// @name         Gitlab artifacts
// @version      0.1
// @description  Get permalinks to artifact files independent of the job ID
// @author       Thorsten Wißmann
// ==/UserScript==

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

function extractBranchName() {
    for (let headcont of document.getElementsByClassName("header-content")) {
        for (let refname of document.getElementsByClassName("ref-name")) {
            if (!('href' in refname)) {
                continue;
            }
            // the branch name is in the text content
            var branchname = refname.textContent;
            // but to be sure we have the right a-tag, we double
            // check with the url:
            var regexp = new RegExp("/-/commits/" + branchname, "i");
            var m = refname.href.match(regexp);
            if (m != undefined) {
                return branchname;
            }
        }
    }
    return undefined;
}

function getPermalinks(jobname, branchname, url) {
    // in the url we have to replace the
    //      /-/jobs/JOBNUMBER/artifacts/
    // by
    //      /-/jobs/artifacts/master/
    // and append ?job=JOBNAME
    view_url = url.replace(/\/-\/jobs\/[0-9]+\/artifacts\//i,
                       "/-/jobs/artifacts/" + branchname + "/")
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
            addLinksToNode(links, div);
        }
    }
}

function addLinksToNode(links, parentNode) {
    for (l of links) {
        var a = document.createElement('a')
        var linkText = document.createTextNode(l.title);
        a.appendChild(linkText);
        a.href = l.url;
        a.classList.add('btn', 'btn-default');
        a.style.marginLeft = '5px';
        parentNode.appendChild(a);
    }
}

function addLinksToDirectoryEntries(jobname, branchname) {
    for (let tr of document.getElementsByClassName("tree-item")) {
        if (!tr.hasAttribute('data-link')) {
            continue;
        }
        var url = tr.getAttribute('data-link');
        /* add it to the last column */
        var lastTd = undefined;
        for (let td of tr.getElementsByTagName('td')) {
            lastTd = td;
        }
        if (lastTd != undefined) {
            var links = getPermalinks(jobname, branchname, url);
            addLinksToNode(links, lastTd);
        }
    }
}

/**
 * Main
 */
(function() {
    if (isGitlab()) {
        var jobname = extractJobName();
        var branchname = extractBranchName();
        if (branchname == undefined) {
            branchname = 'master';
        }
        if (jobname != undefined) {
            addLinksToDirectoryEntries(jobname, branchname);
            addLinks(getPermalinks(jobname, branchname, window.location.href));
        }
    }
})();
