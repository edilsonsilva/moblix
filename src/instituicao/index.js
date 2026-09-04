const route = require("express").Router();
const conexao = require("../database/config.js")



route.post("/insert",(req,res)=>{
    conexao.query(`INSERT INTO instituicoes SET ?`,req.body,(error,result)=>{
        if(error){
        return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
    }
    return res.status(201).send({flag:`OK`,payload:result})
    })
});

route.get("/list",(req,res)  =>{
    conexao.query(`SELECT * FROM instituicoes`,(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_id/:id",(req,res)=>{
    conexao.query(`SELECT * FROM instituicoes WHERE id=?`,req.params.id,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_cnpj/:cnpj",(req,res)=>{
    conexao.query(`SELECT * FROM instituicoes WHERE cnpj=?`,req.params.cnpj,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_tipo/:tipo",(req,res)=>{
    conexao.query(`SELECT * FROM instituicoes WHERE tipo=?`,req.params.tipo,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_nome/:nome",(req,res)=>{
    const q = `%${req.params.nome}%`
    conexao.query(`SELECT * FROM instituicoes WHERE nome LIKE ?`,q,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})
route.put("/update/:id",(req,res)=>{
    conexao.query(`UPDATE instituicoes SET ? WHERE id = ?`,[req.body, req.params.id],(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao tentar atualizar os dados da instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,playload:result})
    })
})

module.exports = route;